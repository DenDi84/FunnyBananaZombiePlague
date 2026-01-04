AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );

function ENT:Initialize()
	self:SetModel("models/weapons/yurie_rustalpha/wm-flare.mdl");
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_NONE);
	self:DrawShadow(false);
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetHealth(self.MaxHealth);
	local phys = self:GetPhysicsObject()  	
	if IsValid(phys) then 
		phys:Wake();
		phys:EnableDrag( false );
		phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
		phys:SetBuoyancyRatio(0);
	end
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON );
	self:Fire("kill", 1, 60);
end

function ENT:Think()
	
end
function ENT:OnRemove()
	local fx = EffectData();
	fx:SetOrigin(self:GetPos() + Vector(0,0,2));
	util.Effect("cball_explode", fx, true, true);
	self:EmitSound("zombie_spark");
end

function ENT:OnTakeDamage( dmginfo )
	local health = self:Health() - dmginfo:GetDamage();
	self:SetHealth( health );
	if ( health <= 0 ) then
		self:Remove();
	end
end
