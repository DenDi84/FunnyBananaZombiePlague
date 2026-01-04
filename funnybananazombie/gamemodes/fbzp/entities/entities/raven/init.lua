AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );

ENT.Mins = Vector( -5, -5, 0 )
ENT.Maxs = Vector(  5,  5,  10 )

function ENT:Initialize()
	self:SetModel( "models/crow.mdl" );
	self:SetMoveType( MOVETYPE_VPHYSICS	);
	self.AutomaticFrameAdvance = true;
	self:SetCollisionBounds( self.Mins, self.Maxs );
	self:PhysicsInitBox( self.Mins, self.Maxs );
	self:SetSolid( SOLID_VPHYSICS );
	self:EnableCustomCollisions( true );
	-- self:DrawShadow( false );
	self:StartMotionController();

	local phys = self:GetPhysicsObject();
	phys:Wake();
	phys:SetMass(10);
	phys:SetMaterial("flesh");

	self.ThirdPersonCam = ents.Create("prop_vehicle_prisOner_pod")
	self.ThirdPersonCam:SetModel("models/nova/airboat_seat.mdl")
	self.ThirdPersonCam:SetPos(self:GetPos());
	-- self.ThirdPersonCam:SetPos(self:GetPos() + self:GetForward()*-30 + self:GetUp()*20);
	self.ThirdPersonCam:SetAngles(self:GetAngles() + Angle(0,270,0))
	self.ThirdPersonCam:Spawn()
	self.ThirdPersonCam:SetParent(self)
	self.ThirdPersonCam:SetNoDraw( true );

end

function ENT:CheckPilot()
	self.Pilot = self:GetChildren()[1]:GetDriver();
	if (IsEmpty(self.Pilot)) then
		self:Remove();
	end
	return !IsEmpty(self.Pilot);
end

function ENT:Think()
	if (!self:CheckPilot()) then
		return;
	end
	local landpos = self:GetGroundPos();
	if (landpos) then
		self.setup.landpos = landpos;
	end
	local speed = self:GetVelocity():Length();
	self:ResetSequence( self.setup.sequence );

	if ( !self.fly and self.Pilot:KeyDown(IN_JUMP) ) then
		self.fly = true;
		self:StartMotionController();
	end

	if ( !self.fly and self.Pilot:KeyDown(IN_FORWARD) ) then
		self.fly = true;
		self:StartMotionController();
	end
	
	if ( self:MountIsOnGround() ) then
		if ( speed >= 2 and speed < 50 ) then
			self.setup.sequence = "Walk";
		elseif ( speed >= 50 ) then
			self.setup.sequence = "Run";
		elseif ( speed < 2 and self.Pilot:KeyDown(IN_ATTACK) ) then
			self.setup.sequence = "Eat_A";
		else
			self.setup.sequence = "Idle01";
			self.speed.current = 0;
		end
	else
		if ( speed > 2 and speed < 20 ) then
			self.setup.sequence = "Hop";
		elseif ( self.Pilot:KeyDown(IN_DUCK) ) then
			self.setup.sequence = "Land";
		elseif ( self.Pilot:KeyDown(IN_JUMP) ) then
			self.setup.sequence = "Fly01";
		elseif ( self.Pilot:KeyDown(IN_FORWARD) ) then
			self.setup.sequence = "Fly01";
		elseif ( speed > 20 ) then
			self.setup.sequence = "Soar";
		else
			self.setup.sequence = "Land";
		end
	end
	self:PhysWake();
	self:GetPhysicsObject():Wake();
	self:NextThink(CurTime());
end

function ENT:PhysicsSimulate( phys, deltatime )
	if ( !IsValid( self.Pilot ) or !self.Pilot:Alive() or !self.Pilot:InVehicle() ) then
		self:StopMotionController();
		return SIM_NOTHING;
	end
	local isground = self:MountIsOnGround();
	local ang = self.Pilot:GetAimVector():Angle();
	if ( !self.fly ) then
		self.PhysicsParams.pos = self:GetPos()+self:GetForward()*self.speed.current;
		ang.z = self.speed.strafe;
		self.PhysicsParams.angle = ang;
		self.PhysicsParams.teleportdistance = 0;
		self.PhysicsParams.deltatime = deltatime;
		phys:ComputeShadowControl( self.PhysicsParams );
		phys:Wake();
		return SIM_NOTHING;
	end
	self.PhysicsParams.pos = self:GetPos();
	self.PhysicsParams.angle = ang;

	if (self.Pilot:KeyDown(IN_FORWARD) and self.speed.current < self.speed.max) then
		self.speed.current = self.speed.current + (math.abs(self.speed.max) / 100) * 2;
	elseif (self.Pilot:KeyDown(IN_BACK) and self.speed.current > self.speed.min) then
		self.speed.current = self.speed.current - 10;
	else
		self.speed.current = self.speed.current - .5;
	end
	if ( self.speed.current > self.speed.max ) then self.speed.current = self.speed.max; end
	if ( self.speed.current < self.speed.min ) then self.speed.current = self.speed.min; end

	-- правый стрейф (40 угол на который наклонится транспорт)
	if( self.Pilot:KeyDown(IN_MOVERIGHT) and self.speed.strafe < 90) then
		self.speed.strafe = self.speed.strafe + (math.abs(90) / 100) * 2;
	elseif(self.Pilot:KeyDown(IN_MOVELEFT) and self.speed.strafe > -90) then
		self.speed.strafe = self.speed.strafe - (math.abs(90) / 100) * 2;
	elseif ( self.speed.strafe > 0) then
		self.speed.strafe = self.speed.strafe - 1;
	elseif (self.speed.strafe < 0) then
		self.speed.strafe = self.speed.strafe + 1;
	end

	if ( isground and self:GetVelocity():Length() > 200 ) then
		self.speed.current = self.speed.max / 5;
	end
	if ( self.Pilot:KeyDown(IN_JUMP) ) then
		self.speed.up = self.speed.up + 5;
	else
		self.speed.up = self.speed.up - 1;
	end
	if ( self.speed.up > self.speed.maxup ) then self.speed.up = self.speed.maxup; end
	if ( self.speed.up < 0 and !self.Pilot:KeyDown(IN_DUCK) ) then self.speed.up = 0; end

	if(self.Pilot:KeyDown(IN_WALK) and self.speed.current > 20 and isground) then
		self.speed.current = 20;
	end
	if(self.Pilot:KeyDown(IN_DUCK) and self:GetPos():Distance(self.setup.landpos) < 4) then
		self.PhysicsParams.pos = self.setup.landpos;
		ang = self:GetAngles();
	else
		self.PhysicsParams.pos = self:GetPos()+self:GetForward()*self.speed.current+self:GetUp()*self.speed.up;
		ang.z = self.speed.strafe;
	end
	if ( isground ) then
		ang.z = 0;
	end


	self.PhysicsParams.angle = ang;
	self.PhysicsParams.teleportdistance = 0;
	self.PhysicsParams.deltatime = deltatime;
	phys:ComputeShadowControl( self.PhysicsParams );
	phys:Wake();
end


function ENT:PhysicsCollide(cdat, phys)
	if ( !self:MountIsOnGround() ) then
		self.speed.current = 0;
		self.fly = false;
	end
end


function ENT:MountIsOnGround()
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = trace.start + Vector( 0, 0, -2 )
	trace.mask = MASK_SOLID_BRUSHONLY
	local tr = util.TraceEntity( trace, self.Entity )
	return tr.HitWorld
end

function ENT:GetGroundPos()
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = trace.start - Vector(0,0,20000);
	trace.mask = MASK_SOLID_BRUSHONLY
	local tr = util.TraceEntity( trace, self.Entity )
	if (tr.HitWorld) then 
		return tr.HitPos;
	else
		return false;
	end
end


function ENT:OnTakeDamage( dmginfo )
	self.Pilot:TakeDamage( dmginfo:GetDamage(), dmginfo:GetAttacker(), dmginfo:GetInflictor() );
	if (self.Pilot:Health() <= 0) then
		self.Pilot:SetPos( self:GetPos() );
		self.Pilot:SetNoDraw( false );
		self:Remove();
	end
end
function ENT:SetPilot( ply )
	ply:ExitVehicle();
	ply:SetModel( self:GetModel() );
	ply:EnterVehicle(self:GetChildren()[1]);
	ply:SetNoDraw( true );
	ply:StripWeapons();
	ply:SetNWBool("raven", true);
	ply:AddFlags( FL_ATCONTROLS );
end
function ENT:OnRemove()
	if (IsValid(self.Pilot)) then
		self.Pilot:ExitVehicle();
		self.Pilot:RemoveFlags( FL_ATCONTROLS );
		self.Pilot:SetMoveType( MOVETYPE_WALK );
		self.Pilot:SetViewEntity( NULL );
		self.Pilot:SetNWBool("raven", false);
	end
end


-- 0	=	Fly01
-- 1	=	Idle01
-- 2	=	Walk
-- 3	=	Run
-- 4	=	Eat_A
-- 5	=	Eat_B
-- 6	=	Takeoff
-- 7	=	Soar
-- 8	=	Land
-- 9	=	Land_b
-- 10	=	Hop
-- 11	=	Hop_B
-- 12	=	reference
-- 13	=	lamarr_crow
-- 14	=	ragdoll