AddCSLuaFile();

SWEP.PrintName = "Spitter Claws"

SWEP.Category = "Left 4 Dead 2"

SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 50
SWEP.ViewModel = "models/weapons/arms/v_spitter_arms.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFlip = false

SWEP.SwayScale = 0.5
SWEP.BobScale = 0.5

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 0

SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.UseHands = false
SWEP.HoldType = "fist"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"
SWEP.TimeTeleport = 0;

-- SWEP.WalkSpeed = 250
-- SWEP.RunSpeed = 500

SWEP.Idle = 0
SWEP.IdleTimer = CurTime()

SWEP.Melee = 0
SWEP.Spit = 0

SWEP.Primary.Sound = Sound( "Zombie.AttackMiss" )
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 1000;
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 1
SWEP.Primary.Force = 5000

SWEP.Secondary.Sound = Sound( "spitterZombie.Pounce" )
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Damage = 80
SWEP.Secondary.Delay = 1.5
SWEP.Secondary.Force = 10000


function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self.Idle = 0
	self.IdleTimer = CurTime() + 1
end

function SWEP:Deploy()
	self:SetWeaponHoldType( self.HoldType )
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	self.Melee = 0
	self.Spit = 0
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	-- self.Owner:SetWalkSpeed( self.WalkSpeed )
	-- self.Owner:SetRunSpeed( self.RunSpeed )
end

function SWEP:Holster()
	if self.Melee == 1 then return end
	if self.Spit == 1 then return end
	self.Idle = 0
	self.IdleTimer = CurTime()
	return true
end

function SWEP:PrimaryAttack()
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:EmitSound( self.Primary.Sound )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self.Melee = 1
	timer.Simple( 0.1, function()
	if self.Melee == 1 then
	self.Owner:LagCompensation( true )
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 90,
		filter = self.Owner,
		mask = MASK_SHOT_HULL,
	} )
	if (!IsValid( tr.Entity )) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 90,
			filter = self.Owner,
			mins = Vector( -16, -16, 0 ),
			maxs = Vector( 16, 16, 0 ),
			mask = MASK_SHOT_HULL,
		} );
	end
	if (SERVER and tr.Hit and !( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 )) then
		self.Owner:EmitSound( "Zombie.Punch" )
	end
if SERVER and IsValid( tr.Entity ) then
	local dmginfo = DamageInfo()
	local attacker = self.Owner
	if !IsValid( attacker ) then
		attacker = self
	end
	dmginfo:SetAttacker( attacker )
	dmginfo:SetInflictor( self )
	dmginfo:SetDamage( self.Primary.Damage )
	dmginfo:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
	tr.Entity:TakeDamageInfo( dmginfo )
	if tr.Hit then
		self.Owner:EmitSound( "Zombie.Punch" )
	end
end
self.Owner:ViewPunchReset()
self.Owner:ViewPunch( Angle( -10 * self.Primary.Recoil, 0, 0 ) )
self.Melee = 0
end
end )
end

	function SWEP:SecondaryAttack()
		if ( self.TimeTeleport < CurTime() ) then
			self.TimeTeleport = CurTime() + 10;
			local point = false;
			if (SERVER) then
				-- local point = MAP:SpawnPoints( true );
				-- self.Owner:SetPos( point.pos );
			end
			point = FindPointToSpawn(self.Owner:GetEyeTrace().HitPos, 4);
			if (point) then
				self.Owner:SetPos( point );
				local fx = EffectData();
				fx:SetOrigin( self:GetPos() );
				util.Effect("explode_health", fx);
				self:EmitSound("weapons/airboat/airboat_gun_energy1.wav", 95, 110);
			end
		end
	end

	function SWEP:Reload()
	end

	function SWEP:Think()
		if self.Idle == 0 and self.IdleTimer > CurTime() and self.IdleTimer < CurTime() + 0.1 then
		self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
		self.Idle = 1
	end
end

if CLIENT then
	function SWEP:Think()
		local am_nightvision = DynamicLight( self:GetOwner():EntIndex() )
		if ( am_nightvision ) then
			am_nightvision.Pos = self:GetOwner():EyePos();
			am_nightvision.r = 255
			am_nightvision.g = 14
			am_nightvision.b = 10
			am_nightvision.Brightness = 1
			am_nightvision.Size = 3000
			am_nightvision.DieTime = CurTime()+100000
			am_nightvision.Style = 1
		end
	end
end