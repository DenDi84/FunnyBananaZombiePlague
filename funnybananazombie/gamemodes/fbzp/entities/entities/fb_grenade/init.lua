AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );

function ENT:Initialize()
	-- self:PhysicsInitBox(Vector(-2,-2,0), Vector(2,2,5));
	self:PhysicsInit( SOLID_VPHYSICS )
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
	self:Fire("kill", 1, self.Grenade.ExplodeDelay);
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON );
end

function ENT:Think()
	if (self.Weapon != nil) then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
	end
end

function ENT:Touch( entity )
	if ( self.Grenade.ExplodeOnTouch and entity != self.Owner and entity:IsPlayer() ) then
		self:Remove();
	end
	return true;
end

function ENT:PhysicsCollide( data, phys )
	self.LastTouch = data.HitPos;
	if (self.Grenade.ExplodeOnCollide) then
		self:Remove();
	else
		if ( data.Speed > 50 ) then self:EmitSound( Sound( "Flashbang.Bounce" ) ) end
		local coef = data.Speed / 500;
		phys:SetVelocity(Vector(phys:GetVelocity().x * coef,phys:GetVelocity().y * coef,phys:GetVelocity().z));
	end
end

function ENT:OnRemove()
	if (self.Grenade.ExplodeSound) then
		self:EmitSound(self.Grenade.ExplodeSound);
	end
	if (IsValid(self.Inflictor)) then
		self.Inflictor:GrenadeExplode( self:GetPos(), self:GetAngles() );
		if ( self.Inflictor.Owner:GetAmmoCount( self.Inflictor.Primary.Ammo ) <= 0) then
			self.Inflictor.Owner:StripWeapon(self.Inflictor:GetClass());
			-- self.Owner:SelectWeapon("zp_knife");
			self.Owner:ConCommand("lastinv");
		end
	end
end


function ENT:PhysicsUpdate(phys)
	if not self.Hit then
		-- self:SetLocalAngles(phys:GetVelocity():Angle())
	else
		phys:SetVelocity(Vector(phys:GetVelocity().x * 0.95,phys:GetVelocity().y * 0.95,phys:GetVelocity().z));
	end
end
