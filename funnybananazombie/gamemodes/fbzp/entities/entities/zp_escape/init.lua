AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );

function ENT:Initialize()

	for i,v in ipairs(ents.GetAll()) do
		if (v:GetClass() == "zp_escape" and v != self) then
			v:Remove();
		end
	end

	self:SetModel( "models/nexuselite/ch46e_fly.mdl" );
	-- self:EmitSound("aheli_rotor");

	local filter = RecipientFilter();
	filter:AddAllPlayers();
	self.sound = CreateSound( self, "npc/attack_helicopter/aheli_rotor_loop1.wav", filter );
	self.sound:Play();

	
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:SetSolid( SOLID_VPHYSICS );
	self:PhysicsInit( SOLID_VPHYSICS );

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	phys:SetMass( 10000 );
	self:StartMotionController();

	self:DrawBox("models/hunter/plates/plate1x3.mdl", {forward = 215, top = -98, right = 0}, Angle(0,0,25));
	self:DrawBox("models/hunter/plates/plate1x8.mdl", {forward = 40, top = -20, right = 43}, Angle(80,0,2));
	self:DrawBox("models/hunter/plates/plate1x8.mdl", {forward = 40, top = -20, right = -43}, Angle(-80,0,2));
	self:DrawBox("models/hunter/plates/plate1x8.mdl", {forward = 40, top = 22, right = 0}, Angle(0,0,3));
	self:DrawBox("models/hunter/blocks/cube2x2x2.mdl", {forward = -210, top = -20, right = 0}, Angle(0,0,0));
	self:DrawBox("models/hunter/blocks/cube1x2x1.mdl", {forward = -160, top = 50, right = 0}, Angle(0,0,0));
	self:DrawBox("models/hunter/blocks/cube2x2x1.mdl", {forward = 250, top = 60, right = 0}, Angle(90,0,0));
	self:DrawBox("models/hunter/blocks/cube1x2x1.mdl", {forward = 170, top = 60, right = 0}, Angle(0,0,90));
	self:DrawBox("models/hunter/blocks/cube1x2x1.mdl", {forward = 100, top = -50, right = 70}, Angle(0,0,0));
	self:DrawBox("models/hunter/blocks/cube1x2x1.mdl", {forward = 100, top = -50, right = -70}, Angle(0,0,0));


	self:DrawSeat({forward = 103, top = -47, right = 30}, Angle(0,90,0));
	self:DrawSeat({forward = 81, top = -46, right = 30}, Angle(0,90,0));
	self:DrawSeat({forward = 59, top = -45, right = 30}, Angle(0,90,0));
	self:DrawSeat({forward = 32, top = -43, right = 30}, Angle(0,90,0));
	self:DrawSeat({forward = 11, top = -42, right = 30}, Angle(0,90,0));
	self:DrawSeat({forward = -10, top = -41, right = 30}, Angle(0,90,0));
	self:DrawSeat({forward = -113, top = -34, right = 30}, Angle(0,90,0));
	self:DrawSeat({forward = -92, top = -35, right = 30}, Angle(0,90,0));
	self:DrawSeat({forward = -86, top = -37, right = -30}, Angle(0,270,0));
	self:DrawSeat({forward = -65, top = -38, right = -30}, Angle(0,270,0));
	self:DrawSeat({forward = -44, top = -39, right = -30}, Angle(0,270,0));
	self:DrawSeat({forward = -22, top = -41, right = -30}, Angle(0,270,0));
	self:DrawSeat({forward = -1, top = -42, right = -30}, Angle(0,270,0));
	self:DrawSeat({forward = 20, top = -43, right = -30}, Angle(0,270,0));
	self:DrawSeat({forward = 41, top = -44, right = -30}, Angle(0,270,0));
	self:DrawSeat({forward = 63, top = -45, right = -30}, Angle(0,270,0));
	self:DrawSeat({forward = 84, top = -46, right = -30}, Angle(0,270,0));
	self:DrawSeat({forward = 105, top = -47, right = -30}, Angle(0,270,0));
	self:DrawSeat({forward = 127, top = -48, right = -30}, Angle(0,270,0));


	self.target = self.point[1];
end

function ENT:OnRemove()
	self.sound:Stop();
	self:StopSound( "escape_alarm" );
	self:StopSound( "escape_explode" );
end

function ENT:PhysicsSimulate( phys, deltatime )
	local FlightPhys = {
		pos = self.target.pos,
		secondstoarrive	= .1,
		maxangular		= 15,
		maxangulardamp	= 10000,
		maxspeed			= 300,
		maxspeeddamp		= 500000,
		dampfactor		= 0.8,
		teleportdistance	= 500000
	};
	FlightPhys.angle = self.target.ang - Angle(0,90,0);
	FlightPhys.deltatime = deltatime;
	phys:ComputeShadowControl(FlightPhys);
	phys:Wake();
end

function ENT:DrawBox( model, pos, angle )
	local box = ents.Create("prop_physics");
	box:SetSolid( SOLID_VPHYSICS );
	box:SetNoDraw( true );
	box:SetModel( model );
	box:SetPos(self:GetPos() + self:GetRight() * pos.forward + self:GetUp() * pos.top + self:GetForward() * pos.right);
	box:SetAngles( self:GetAngles() + angle );
	box:SetParent( self );
	return box;
end

function ENT:DrawSeat( pos, angle )
	local seat = ents.Create( "prop_vehicle_prisOner_pod" );
	seat:SetModel("models/nova/airboat_seat.mdl");
	seat:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	seat:SetPos(self:GetPos() + self:GetRight() * pos.forward + self:GetUp() * pos.top + self:GetForward() * pos.right);
	seat:SetAngles( self:GetAngles() + angle );
	seat:SetParent( self );
	seat:SetNoDraw( true );
	seat:Spawn();
	seat:Activate();
	seat:SetSolid( SOLID_NONE );
	seat:SetUseType(SIMPLE_USE);
	seat:GetPhysicsObject():EnableCollisions(false);
end

function ENT:Think()
	self.sound:Play();
	if (self:GetPos():DistToSqr( self.target.pos ) < 10 and !self.wait) then
		self.wait = true;
		local sleep = self.target.fun( self );
		if (sleep > 0) then
			timer.Create( "WaitNextPointZPESCAPE", sleep, 1, function()
				if (IsValid(self)) then self:NextStep(); end
			end );
		else
			self:NextStep();
		end
	end
end

function ENT:NextStep()
	self.step = self.step + 1;
	if (self.point[self.step] != nil) then
		self.wait = false;
		self.target = self.point[self.step];
	else
		self.wait = true;
	end
end

function ENT:WaitPassenger( enable )
	if (enable) then
		self:EmitSound( "escape_alarm" );
	else
		self:StopSound( "escape_alarm" );
	end
end

function ENT:Explode()
	local check = function( ply )
		if (ply:InVehicle() and IsValid( ply:GetVehicle():GetParent() ) and ply:GetVehicle():GetParent():GetClass() == "zp_escape") then return true; end
		for i,v in ipairs( ents.FindInBox( self:GetPos() + self:GetRight() * 300 + self:GetUp() * -140 + self:GetForward() * -90, self:GetPos() + self:GetRight() * -300 + self:GetUp() * 160 + self:GetForward() * 90 ) ) do
			if ( v:IsPlayer() and v == ply ) then
				return true;
			end
		end
		return false;
	end
	for i,v in ipairs(player.GetAll()) do
		if (!check(v)) then
			-- Убиваем
			v:EmitSound("escape_explode");
			util.ScreenShake( v:GetPos(), 5, 5, 10, 5000 );
			v:Ignite( 10, 10 );
			v:ScreenFade( SCREENFADE.IN, Color( 255, 0, 0, 128 ), 0.3, 0 );
			v:TakeDamage( 5000, v, v );
		else
			-- Даём деньги
			v:AddMoney( 100 );
		end
	end
	zombieplague.round.time = 1;
end

function ENT:Use( ply )
	for i,v in ipairs(self:GetChildren()) do
		if (v:GetClass() == "prop_vehicle_prisOner_pod" and v:GetPassenger( 1 ) == NULL) then
			ply:EnterVehicle( v );
			ply:SetAllowWeaponsInVehicle( true );
			ply:SetCollisionGroup(COLLISION_GROUP_PLAYER);
			break;
		end
	end
end

hook.Add( "PlayerLeaveVehicle", "PlayerLeaveZPESCAPE", function( ply, veh )
	local parent = veh:GetParent();
	if ( IsValid(parent) and parent:GetClass() == "zp_escape" ) then
		local standartpos = parent:GetPos() + parent:GetRight() * 285 + parent:GetUp() * -100;
		local spawnpos = FindPointToSpawn( standartpos, 20 );
		if (spawnpos) then
			ply:SetPos( spawnpos );
		else
			ply:SetPos( standartpos );
		end
	end
end )


concommand.Add( "zp_escape", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	zombieplague:CreateEscape();
end );

concommand.Add( "mypos", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	local pos = ply:GetPos();
	local ang = ply:GetAngles();
	print("{");
	print("	pos = Vector("..pos.x..", "..pos.y..", "..pos.z.."),");
	print("	ang = Angle("..ang.x..", "..ang.y..", "..ang.z.."),");
	print("	fun = function( self )");
	print("		return 0;");
	print("	end");
	print("},");
end );
