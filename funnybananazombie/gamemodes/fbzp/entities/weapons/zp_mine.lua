AddCSLuaFile();

SWEP.PrintName = "ZombiePlague Mine";
SWEP.Author = "FunnyBanana";
SWEP.Base = "weapon_base";
SWEP.HoldType = "slam";
SWEP.ViewModelFOV = 140;
SWEP.ViewModelFlip = false;
SWEP.UseHands = false;
SWEP.ViewModel = nil;
SWEP.WorldModel = "models/funnybanana/zp_mine.mdl";
SWEP.DrawViewModel = false;
SWEP.DrawWorldModel = false;
SWEP.Slot = 5;
SWEP.SlotPos = 1;

SWEP.BounceWeaponIcon = false;
SWEP.DrawWeaponInfoBox = false;
if (CLIENT) then
	SWEP.WepSelectIcon = surface.GetTextureID( "icons/swep/lasermine" );
end


SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = 10;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Ammo = "mine";

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;

SWEP.Secondary.Recoil = -1;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Ammo = "none";

SWEP.Weight = 1;

util.PrecacheModel( "models/funnybanana/zp_mine.mdl" );

local ENT = {};


SWEP.Distance = 80;
SWEP.SetTime = 20;
SWEP.SetTimer = 20;

SWEP.modellaser = {};

SWEP.time = {
	delay = 100,
	timer = 100,
	pause = 200
};
ENT.MaxHealth = 20;


game.AddAmmoType( {
	name = "mine",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} );


if CLIENT then
	local WorldModel = ClientsideModel(SWEP.WorldModel);
	WorldModel:SetNoDraw(true);

	function SWEP:DrawWorldModel()
		local _Owner = self:GetOwner()

		if (IsValid(_Owner)) then
            -- Specify a good position
			local offsetVec = Vector(5, -4, -3)
			local offsetAng = Angle(180, 0, 180)
			
			local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
			if !boneid then return end

			local matrix = _Owner:GetBoneMatrix(boneid)
			if !matrix then return end

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

			WorldModel:SetPos(newPos)
			WorldModel:SetAngles(newAng)

            WorldModel:SetupBones()
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
		end

		WorldModel:DrawModel()
	end
end

function SWEP:ShouldDrawViewModel()
	return false;
end
function SWEP:ShouldDrawWorldModel()
	return true;
end

function SWEP:TakePrimaryAmmo( amount )
	
end

function SWEP:PrimaryAttack()
	if (self:CanCreate() and self.time.timer <= 0) then
		self.time.timer = self.time.delay + self.time.pause;
		self:SetNWInt("timer", self.time.delay);
		self:CreateMine();
		if (self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
			self.Owner:RemoveAmmo(1, self.Primary.Ammo);
		elseif (self.Owner:GetAmmoCount(self.Primary.Ammo) == 0) then
			self.Owner:ConCommand("lastinv");
		end
		self.Owner:SetNWInt( "lasermine", self.Owner:GetAmmoCount(self.Primary.Ammo));
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		local trace = self.Owner:GetEyeTrace();
		if (trace.HitPos:Distance(self.Owner:GetPos()) < self.Distance and IsValid(trace.Entity) and trace.Entity:GetClass() == "lasermine" and self.Owner == trace.Entity.Owner) then
			self.Owner:GiveAmmo(1, self.Primary.Ammo);
			trace.Entity:Remove();
			self.Owner:SetNWInt( "lasermine", self.Owner:GetAmmoCount(self.Primary.Ammo));
		end
	end
	return false;
end

function SWEP:Initialize()
	if SERVER then
		self:SetHoldType( self.HoldType );
	end
	if CLIENT then
		self.modellaser = ClientsideModel("models/funnybanana/zp_mine.mdl", RENDERGROUP_TRANSLUCENT);
		self.modellaser:SetNoDraw( true );
	end
end

function SWEP:OnRemove()
	if CLIENT then
		if (IsValid(self.modellaser)) then
			self.modellaser:Remove();
		end
	end
end

function SWEP:Deploy()
	self.Owner:SetAmmo( self.Owner:GetNWInt( "lasermine", 1 ), self.Primary.Ammo );
	if (self.Owner:GetAmmoCount(self.Primary.Ammo) > SHOP.items.lasermine.limit) then
		self.Owner:SetAmmo( SHOP.items.lasermine.limit, self.Primary.Ammo );
		self.Owner:SetNWInt( "lasermine", SHOP.items.lasermine.limit )
	end
	if ( CLIENT and IsValid( self.modellaser ) and self.modellaser != NULL ) then
		self.modellaser:SetNoDraw( true );
	end
end

function SWEP:Holster( wep )
	if ( CLIENT and IsValid( self.modellaser ) and self.modellaser != NULL ) then
		self.modellaser:SetNoDraw( true );
	end
	return true;
end

function SWEP:Think()
	if SERVER then
		if (self.Owner:KeyDown( IN_ATTACK ) and self:CanCreate()) then
			self.time.timer = self.time.timer - 1;
		else
			self.time.timer = self.time.delay;
		end
		self:SetNWInt("timer", self.time.timer);
	end
	if (CLIENT and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
		if ( !IsValid( self.modellaser ) ) then
			self.modellaser = ClientsideModel("models/funnybanana/zp_mine.mdl", RENDERGROUP_TRANSLUCENT);
		end
		local trace = LocalPlayer():GetEyeTrace();
		if ( IsValid(trace.Entity) and !IsEmpty(trace.Entity:GetParent()) and trace.Entity:GetClass() == "lasermine" ) then 
			self.modellaser:SetNoDraw( true );
			return;
		end
		if ( trace and trace.HitPos:Distance(LocalPlayer():GetPos()) < self.Distance ) then
			self.modellaser:SetPos( trace.HitPos );
			self.modellaser:SetAngles( trace.HitNormal:Angle());
			self.modellaser:SetNoDraw( false );
			return;
		end
		self.modellaser:SetNoDraw( true );
	end
	if (CLIENT and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 and IsValid( self.modellaser )) then
		self.modellaser:SetNoDraw( true );
	end
end


function SWEP:CreateMine()
	if (SERVER and IsValid( self.Owner ) and self:CanCreate()) then
		local mine = ents.Create("lasermine");
		local trace = self.Owner:GetEyeTrace();
		mine:SetPos( trace.HitPos );
		mine:SetAngles( trace.HitNormal:Angle());
		mine:Spawn();
		mine.Inflictor = self.Weapon;
		mine.Owner = self.Owner;
		mine.Team = self.Owner:Team();
		mine:SetNWInt("Team", mine.Team);
		mine:SetNWEntity( "owner", self.Owner );
		mine:Activate();
	end
	if CLIENT then
		self.modellaser:SetNoDraw( true );
	end
end

function SWEP:CanCreate()
	local trace = self.Owner:GetEyeTrace();
	if (self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then return false end
	if (!IsEmpty(trace.Entity) and trace.Entity:GetClass() == "lasermine") then return false end
	return (trace and trace.HitPos:Distance(self.Owner:GetPos()) < self.Distance );
end


function SWEP:DoDrawCrosshair( x, y )
	self.time.timer = self:GetNWInt("timer", self.time.delay);
	if ( self.time.timer < self.time.delay) then
		local procent = self.time.timer / (self.time.delay / 100);
		local pos = { x = screen().center.x + 54, y = screen().center.y + 22 };
		for i=1,10 do
			local hudcolor = color().white;
			local hudopacity = 110;
			if (math.ceil(procent / 10) > i) then
				hudcolor = color().gray;
				hudopacity = 10;
			end
			leftw = draw.SimpleText( "-", "NumberMiniBlur", pos.x, pos.y - 40, ColorAlpha( hudcolor, hudopacity ), TEXT_ALIGN_LEFT );
			draw.SimpleText( "-", "NumberMini", pos.x, pos.y - 40, ColorAlpha( hudcolor, hudopacity ), TEXT_ALIGN_LEFT );
			pos.x = pos.x - leftw - 2;
		end
		return true;
	end
end


ENT.Mins = Vector( -5, -5, 0 );
ENT.Maxs = Vector(  5,  5,  10 );

ENT.Type = "anim";
ENT.Base = "base_anim";
ENT.Team = 1;
ENT.Owner = {};
ENT.Scaled = false;
if CLIENT then
	function ENT:Draw()
		self:DrawModel();
	end
end

if SERVER then

	function ENT:Initialize()
		self:SetModel("models/funnybanana/zp_mine.mdl");
		self:SetUseType( SIMPLE_USE );
		self:SetSolid( SOLID_VPHYSICS );
		self:SetMoveType( MOVETYPE_NONE );
		self:DrawShadow(false);
		self:SetMaxHealth( self.MaxHealth );
		self:SetHealth( self.MaxHealth );
		self.WhirrSound = CreateSound(self, "nightvision.wav");
		self.WhirrSound:PlayEx( 0.5, 255 );
	end

	function ENT:OnRemove()
		if (!IsEmpty(self.WhirrSound)) then self.WhirrSound:Stop(); end
	end

	function ENT:Think()
		local trace = util.TraceLine( {
			start = self:GetPos()+self:GetForward()+self:GetForward()*10,
			endpos = self:GetPos()+self:GetForward() * 10000,
			filter = self
		} );
		if (IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:Alive() and trace.Entity:Team() != self.Team) then
			trace.Entity:TakeDamage( 3, self.Owner, self.Inflictor );
			if( trace.Entity:GetPos():Distance( self:GetPos() ) < 50 ) then
				self:Explode();
				if (trace.Entity:Team() == 2) then
					trace.Entity:TakeDamage( math.random(100, 300), self.Owner, self.Inflictor );
					trace.Entity:Ignite( 10, 10 );
				end
			end
		end
		if (IsValid(trace.Entity) and !trace.Entity:IsPlayer() and trace.Entity:GetClass() == "raven") then
			trace.Entity:GetChildren()[1]:TakeDamage( 3, self.Owner, self.Inflictor );
		end
	end

	function ENT:Use( ply )
		if ( SERVER and ply == self.Owner and ply:KeyDown( IN_WALK ) ) then
			ply:GiveAmmo(1, "mine");
			self:Remove();
			self.Owner:SetNWInt( "lasermine", ply:GetAmmoCount("mine"));
		end
	end

	function ENT:OnTakeDamage( dmginfo )
		if ( !IsValid(self.Owner) or IsEmpty(self.Owner) or !self.Owner:IsPlayer() ) then 
			self:Remove();
			return;
		end
		if ( dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():Team() == self.Team ) then return end
		local health = self:Health() - math.random(1,9);
		self:SetHealth( health );
		if ( health <= 0 ) then
			self:Explode();
		end
	end

	function ENT:Explode()
		local fx = EffectData();
		fx:SetOrigin( self:GetPos() );
		util.Effect("cball_explode", fx);
		self:EmitSound("weapons/explode5.wav", 90, 85);
		util.ScreenShake(self:GetPos(), 50, 50, 1, 100);
		self:Remove();
		for k,v in pairs(ents.FindInSphere( self:GetPos(), 100 )) do
			if (v:IsPlayer() or v:GetClass() == "raven") then
				v:TakeDamage( math.random(5, 20), self.Owner, self.Inflictor );
			end
		end
	end

end

scripted_ents.Register(ENT, "lasermine", true);



hook.Add("PreDrawEffects", "draw.VectorSprite", function()
	cam.Start3D( EyePos(), EyeAngles() );
	for k, v in pairs( ents.FindByClass( "lasermine" ) ) do
		local colorbeam = color().white;
		local team = v:GetNWInt("Team", 0);
		if (team == 1) then
			colorbeam = color().blue;
		elseif(team == 2) then
			colorbeam = color().green;
		end

		local trace = util.TraceLine( {
			start = v:GetPos()+v:GetForward()*10,
			endpos = v:GetPos()+v:GetForward() * 16000
		} );
		render.SetMaterial( Material( "sprites/physbeam" ) );
		render.DrawBeam( v:GetPos(), trace.HitPos, 3, 0, 0, ColorAlpha(colorbeam, 255) );
		render.DrawBeam( v:GetPos(), trace.HitPos, 3, 0, 0, ColorAlpha(colorbeam, 255) );
		render.SetMaterial( Material( "sprites/light_glow02_add" ) )
		local ViewNormal = trace.HitPos - EyePos();
		local Distance = ViewNormal:Length();
		local Size = math.Clamp( Distance * 2, 2, 16 );
		render.DrawSprite( trace.HitPos, Size, Size, ColorAlpha(colorbeam, 255) )
		render.DrawSprite( trace.HitPos, Size*0.4, Size*0.4, ColorAlpha(colorbeam, 255) )
	end
	cam.End3D();
end)