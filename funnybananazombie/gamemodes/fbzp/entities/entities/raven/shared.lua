ENT.Type = "anim";
ENT.Base = "base_anim";
ENT.PrintName = "Raven";

ENT.Pilot = {};
ENT.ThirdPersonCam = {};
ENT.fly = false;
ENT.setup = {
	sequence = "Idle01",
	landpos = Vector(0,0,0)
}
ENT.speed = {
	max = 200,
	min = 0,
	current = 0,
	strafe = 0,
	up = 0,
	maxup = 40,
	down = 0,
	maxdown = 50
};
ENT.PhysicsParams = {};
ENT.PhysicsParams.secondstoarrive = .6;
ENT.PhysicsParams.maxangular = 5000;
ENT.PhysicsParams.maxangulardamp = 10000;
ENT.PhysicsParams.maxspeed = 1000000;
ENT.PhysicsParams.maxspeeddamp = 10000;
ENT.PhysicsParams.dampfactor = 0.8;
ENT.PhysicsParams.teleportdistance = 0;