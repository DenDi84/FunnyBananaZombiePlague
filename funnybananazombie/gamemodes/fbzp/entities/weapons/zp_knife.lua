AddCSLuaFile();
DEFINE_BASECLASS( "weapon_base" );

SWEP.PrintName = "ZombiePlague baseknife";
SWEP.Weight = 1;
SWEP.Slot = 2;
SWEP.SlotPos = 1;
SWEP.DrawAmmo = false;
SWEP.DrawCrosshair = true;
SWEP.ViewModelFOV = 65;
SWEP.ViewModelFlip = false;
SWEP.CSMuzzleFlashes	= true;
SWEP.UseHands = true;
SWEP.Author = "FunnyBanana";

SWEP.ViewModel = "models/weapons/v_csgo_m9.mdl"
SWEP.WorldModel = "models/weapons/w_csgo_m9.mdl"

SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo = "none";


SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Damage = -1;
SWEP.Secondary.Automatic = true;
SWEP.Secondary.Ammo = "none";
SWEP.AllowDrop = false;

SWEP.SkinIndex = 11;

SWEP.BounceWeaponIcon = false;
SWEP.DrawWeaponInfoBox = false;
if (CLIENT) then
	SWEP.WepSelectIcon = surface.GetTextureID( "icons/swep/knife" );
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "InspectTime" );
	self:NetworkVar( "Float", 1, "IdleTime" );
end


function SWEP:Initialize()
	self:SetHoldType( "knife" );
	self:SetSkin( 1 );
end



-- PaintMaterial
function SWEP:DrawWorldModel()
	self:SetSkin( 1 );
	self:DrawModel();
end


function SWEP:Think()
	if CurTime()>=self:GetIdleTime() then
		self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
		self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	end
end

function SWEP:Deploy()
	self:SetInspectTime( 0 );
	self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() );
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW );
	self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
	self.Weapon:SetNextSecondaryFire( CurTime() + 1 );
	return true;
end


function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end



function SWEP:FindHullIntersection(VecSrc, tr, Mins, Maxs, pEntity)

	local VecHullEnd = VecSrc + ((tr.HitPos - VecSrc) * 2)

	local tracedata = {}

	tracedata.start	= VecSrc	
	tracedata.endpos = VecHullEnd
	tracedata.filter = pEntity
	tracedata.mask	 = MASK_SOLID
	tracedata.mins	 = Mins
	tracedata.maxs	 = Maxs

	local tmpTrace = util.TraceLine( tracedata )

	if tmpTrace.Hit then
		tr = tmpTrace
		return tr
	end

	local Distance = 999999

	for i = 0, 1 do
		for j = 0, 1 do
			for k = 0, 1 do

				local VecEnd = Vector()

				VecEnd.x = VecHullEnd.x + (i>0 and Maxs.x or Mins.x)
				VecEnd.y = VecHullEnd.y + (j>0 and Maxs.y or Mins.y)
				VecEnd.z = VecHullEnd.z + (k>0 and Maxs.z or Mins.z)

				tracedata.endpos = VecEnd

				tmpTrace = util.TraceLine( tracedata )

				if tmpTrace.Hit then
					ThisDistance = (tmpTrace.HitPos - VecSrc):Length()
					if (ThisDistance < Distance) then
						tr = tmpTrace
						Distance = ThisDistance
					end
				end
			end -- for k
		end -- for j
	end --for i

	return tr
end



function SWEP:PrimaryAttack()
	local prim = true;
	local sec	= true;
	if ( CurTime() < self.Weapon:GetNextPrimaryFire() ) then return end
	self:DoAttack( false ) -- If we can do primary attack, do it. Otherwise - do secondary.
end



function SWEP:SecondaryAttack()
	local prim = true;
	local sec = true;
	if ( CurTime() < self.Weapon:GetNextSecondaryFire() ) then return end
	self:DoAttack( true ) -- If we can do secondary attack, do it. Otherwise - do primary.
end



function SWEP:DoAttack( Altfire )
	local Weapon		= self.Weapon
	local Attacker	= self:GetOwner()
	local Range		 = Altfire and 48 or 64

	Attacker:LagCompensation(true)

	local Forward	 = Attacker:GetAimVector()
	local AttackSrc = Attacker:GetShootPos()
	local AttackEnd = AttackSrc + Forward * Range

	local tracedata = {}

	tracedata.start	 = AttackSrc
	tracedata.endpos	= AttackEnd
	tracedata.filter	= Attacker
	tracedata.mask		= MASK_SOLID
	tracedata.mins		= Vector( -16, -16, -18 ) -- head_hull_mins
	tracedata.maxs		= Vector( 16, 16, 18 ) -- head_hull_maxs

	local tr = util.TraceLine( tracedata )
	if not tr.Hit then tr = util.TraceHull( tracedata ) end
	if tr.Hit and ( not (IsValid(tr.Entity) and tr.Entity) or tr.HitWorld ) then 
		-- Calculate the point of intersection of the line (or hull) and the object we hit
		-- This is and approximation of the "best" intersection
		local HullDuckMins, HullDuckMaxs = Attacker:GetHullDuck()
		tr = self:FindHullIntersection(AttackSrc, tr, HullDuckMins, HullDuckMaxs, Attacker)
		AttackEnd = tr.HitPos -- This is the point on the actual surface (the hull could have hit space)
	end 

	local DidHit = tr.Hit and not tr.HitSky
	local HitEntity = IsValid(tr.Entity) and tr.Entity or Entity(0) -- Ugly hack to destroy glass surf. 0 is worldspawn.
	local DidHitPlrOrNPC = HitEntity and ( HitEntity:IsPlayer() or HitEntity:IsNPC() ) and IsValid( HitEntity )

	local FirstHit = not Altfire and ( ( self.Weapon:GetNextPrimaryFire() + 0.4 ) < CurTime() ) -- First swing does full damage, subsequent swings do less

	tr.HitGroup = HITGROUP_GENERIC -- Hack to disable damage scaling. No matter where we hit it, the damage should be as is.

	-- Calculate damage and deal hurt if we can
	local Backstab	 = DidHitPlrOrNPC and self:EntityFaceBack( HitEntity ) -- Because we can only backstab creatures
	local RMB_BACK	 = 180;
	local RMB_FRONT	= 65;
	local LMB_BACK	 = 90;
	local LMB_FRONT1 = 40;
	local LMB_FRONT2 = 25;

	local Damage = ( Altfire and ( Backstab and RMB_BACK or RMB_FRONT ) ) or ( Backstab and LMB_BACK ) or ( FirstHit and LMB_FRONT1 ) or LMB_FRONT2

	Damage = Damage * 2;

	local Force = Forward:GetNormalized() * 300 * cvars.Number("phys_pushscale", 1) -- simplified result of CalculateMeleeDamageForce()

	local damageinfo = DamageInfo()
 
	damageinfo:SetAttacker( Attacker )
	damageinfo:SetInflictor( self )
	damageinfo:SetDamage( Damage )
	damageinfo:SetDamageType( bit.bor( DMG_BULLET , DMG_NEVERGIB ) )
	damageinfo:SetDamageForce( Force )
	damageinfo:SetDamagePosition( AttackEnd )

	HitEntity:DispatchTraceAttack( damageinfo, tr, Forward )

	if tr.HitWorld then --and ( game.SinglePlayer() or CLIENT ) 

		util.Decal( "ManhackCut", AttackSrc - Forward, AttackEnd + Forward, true );
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
		effectdata:SetStart( tr.StartPos )
		effectdata:SetSurfaceProp( tr.SurfaceProps )
		effectdata:SetDamageType( DMG_SLASH )
		effectdata:SetHitBox( tr.HitBox )
		effectdata:SetNormal( tr.HitNormal )
		effectdata:SetEntity( tr.Entity )
		effectdata:SetAngles( Forward:Angle() )
		util.Effect( "csgo_knifeimpact", effectdata )
	end

	-- Change next attack time
	local NextAttack = Altfire and 1.0 or DidHit and 0.5 or 0.4
	Weapon:SetNextPrimaryFire( CurTime() + NextAttack )
	Weapon:SetNextSecondaryFire( CurTime() + NextAttack )

	-- Send animation to attacker
	Attacker:SetAnimation( PLAYER_ATTACK1 )

	-- Send animation to viewmodel
	local Act = DidHit and ( Altfire and ( Backstab and ACT_VM_SWINGHARD or ACT_VM_HITCENTER2 ) or ( Backstab and ACT_VM_SWINGHIT or ACT_VM_HITCENTER ) ) or ( Altfire and ACT_VM_MISSCENTER2 or ACT_VM_MISSCENTER )
	if Act then
		Weapon:SendWeaponAnim( Act )
		self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	end

	-- Play sound
	-- Sound("...") were added to precache sounds
	local Oldsounds	 = false;
	local StabSnd		 = Sound("csgo_knife.Stab");
	local HitSnd			= Sound("csgo_knife.Hit");
	local HitwallSnd	= Oldsounds and Sound("csgo_knife.HitWall_old") or Sound("csgo_knife.HitWall")
	local SlashSnd		= Oldsounds and Sound("csgo_knife.Slash_old") or Sound("csgo_knife.Slash")

	local Snd = DidHitPlrOrNPC and ( Altfire and StabSnd or HitSnd ) or DidHit and HitwallSnd or SlashSnd
	Weapon:EmitSound( Snd )
	Attacker:LagCompensation(false) -- Don't forget to disable it!
end



function SWEP:Reload()
	
	if self.Owner:IsNPC() then return end -- NPCs aren't supposed to reload it

	local keydown = self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) or self.Owner:KeyDown(IN_ZOOM)
	if not cvars.Bool("csgo_knives_inspecting", true) or keydown then return end

	local getseq = self:GetSequence()
	local act = self:GetSequenceActivity(getseq) --GetActivity() method doesn't work :\
	if ( act == ACT_VM_IDLE_LOWERED and CurTime() < self:GetInspectTime() ) then
		self:SetInspectTime( CurTime() + 0.1 ) -- We should press R repeately instead of holding it to loop
		return end

	self.Weapon:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
	self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	self:SetInspectTime( CurTime() + 0.1 )
end


function SWEP:Holster( wep )
	return true
end



function SWEP:OnRemove()
end



function SWEP:OwnerChanged()
end

--YOU'RE WINNER!
