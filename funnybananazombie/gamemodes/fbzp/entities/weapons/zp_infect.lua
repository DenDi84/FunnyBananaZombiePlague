DEFINE_BASECLASS( "base_anim" );
AddCSLuaFile();

SWEP.Base = "weapon_base";

SWEP.PrintName = "Freeze Grenade";	
SWEP.Author = "FunnyBanana";

SWEP.ViewModel = "models/weapons/tfa_st5/c_st5_green.mdl";
SWEP.WorldModel = "models/weapons/tfa_st5/w_st5_green.mdl";
SWEP.ViewModelFOV = 55;
SWEP.ViewModelFlip = false;
SWEP.UseHands = true;
SWEP.HoldType = "grenade";
SWEP.Slot = 3;
SWEP.SlotPos = 1;
SWEP.Primary.ClipSize = 10;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Ammo = "infect_grenade";


SWEP.Primary.Delay = 1.75;
SWEP.Primary.Automatic = false;
SWEP.Speed = 1400;

SWEP.NextAnimateTime = CurTime();

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;

SWEP.Secondary.Recoil = -1;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Ammo = "none";

game.AddAmmoType( {
	name = "infect_grenade",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} );

function SWEP:Initialize()
	self:SetHoldType( self.HoldType );
end

function SWEP:PrimaryAttack()
	if ( SERVER and self:CanCreate() )then
		self.Owner:RemoveAmmo(1, self.Primary.Ammo);
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
		self:CreateShell();
	end
end

function SWEP:SecondaryAttack()
	return false;
end

function SWEP:CanCreate()
	if ( self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 ) then return false; end
	-- if ( !IsEmpty(EVENTS.round.type) and EVENTS.round.type == "ready" ) then return false; end
	return true;
end

function SWEP:Think()
	if ( SERVER and self.Owner:GetAmmoCount(self.Primary.Ammo) == 0 ) then
		self.Owner:ConCommand("lastinv");
		self:Remove();
	end
	if ( self.NextAnimateTime > CurTime() ) then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
	elseif ( self.Owner:KeyDown(IN_ATTACK) and self.NextAnimateTime < CurTime() and self:CanCreate() ) then
		self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK);
		self.Owner:SetAnimation(PLAYER_ATTACK1);
		self.NextAnimateTime = CurTime() + self.Primary.Delay;
	end
end
function SWEP:Reload()

end

function SWEP:CreateShell()
	local shell = ents.Create("grenade_infect");
	local eyeang = self.Owner:GetAimVector():Angle();
	shell:SetPos(self.Owner:GetShootPos() + eyeang:Right() * 4 + eyeang:Up() * 4);

	shell.Owner = self.Owner;
	shell.Inflictor = self.Weapon;
	shell:SetOwner( self.Owner );

	shell:SetAngles(self.Owner:GetAngles());
	shell:SetPhysicsAttacker(self.Owner);
	shell:Spawn();
	shell:Activate();

	shell:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 95, 110);
	local phys = shell:GetPhysicsObject();
	phys:SetVelocity(self.Owner:GetAimVector() * 1000 + (self.Owner:GetVelocity() * 0.75));
end


local ENT = {};
ENT.Base = "base_anim";
ENT.Type = "anim";
ENT.Radius = 200;

if CLIENT then
	function ENT:Draw()
		self:DrawModel();
	end
end
if SERVER then
	function ENT:Initialize()
		self:SetModel("models/weapons/w_bugbait.mdl");
		self:PhysicsInitBox(Vector(-1,-1,-1), Vector(1,1,1));
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);
		self:DrawShadow(false);
		self:SetTrigger(true);

		local phys = self:GetPhysicsObject()  	
		if IsValid(phys) then 
			phys:Wake();
			phys:EnableDrag( false );
			phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
			phys:SetBuoyancyRatio(0);
		end
		self:Fire("kill", 1, 2);
	end

	function ENT:Think()

	end

	function ENT:Touch( entity )
		if ( entity != self.Owner and entity:IsPlayer() ) then
			self:Remove();
		end
		return true;
	end

	function ENT:OnRemove()
		local fx = EffectData()
		fx:SetOrigin(self:GetPos())
		util.Effect("explode_infect", fx);
		self:EmitSound("weapons/airboat/airboat_gun_energy1.wav", 95, 110);
		for k,v in pairs(ents.FindInSphere( self:GetPos(), self.Radius )) do
			util.ScreenShake(self:GetPos(), 50, 50, 1, self.Radius);
			if (v:IsPlayer() and v:Team() == 1) then
				if ( v:Health() < 100 ) then
					v:Infect( self.Owner, self.Inflictor );
				else
					v:TakeDamage( math.random(5, 90), self.Owner, self.Inflictor );
				end
			end
		end
	end


	function ENT:PhysicsUpdate(phys)
		if not self.Hit then
			self:SetLocalAngles(phys:GetVelocity():Angle())
		else
			phys:SetVelocity(Vector(phys:GetVelocity().x * 0.95,phys:GetVelocity().y * 0.95,phys:GetVelocity().z))
		end
	end

end

scripted_ents.Register(ENT, "grenade_infect", true);
