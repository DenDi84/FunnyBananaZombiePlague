AddCSLuaFile();

SWEP.PrintName = "ZombiePlague barricade";
SWEP.Author = "FunnyBanana";
SWEP.Base = "weapon_base";
SWEP.HoldType = "slam";
SWEP.ViewModelFOV = 140;
SWEP.ViewModelFlip = false;
SWEP.UseHands = false;
SWEP.ViewModel = nil;
SWEP.WorldModel = "models/zombieplague/zp_conus.mdl";
SWEP.DrawViewModel = false;
SWEP.DrawWorldModel = false;
SWEP.Slot = 4;
SWEP.SlotPos = 0;

SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = 10;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Ammo = "ammo_barricade";

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;

SWEP.Secondary.Recoil = -1;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Ammo = "none";

SWEP.Weight = 1;

SWEP.BounceWeaponIcon = false;
SWEP.DrawWeaponInfoBox = false;
if (CLIENT) then
	SWEP.WepSelectIcon = surface.GetTextureID( "icons/swep/barricade" );
end

util.PrecacheModel( "models/zombieplague/zp_conus.mdl" );

local ENT = {};


SWEP.Distance = 80;
SWEP.SetTime = 20;
SWEP.SetTimer = 20;

SWEP.time = {
	delay = 100,
	timer = 100,
	pause = 200
};
ENT.MaxHealth = 100;


game.AddAmmoType( {
	name = "ammo_barricade",
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
			local offsetVec = Vector(3, -9, 0);
			local offsetAng = Angle(0, 0, 0);
			
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


function SWEP:PrimaryAttack()
	if (self:CanCreate() and self.time.timer <= 0) then
		self.time.timer = self.time.delay + self.time.pause;
		self:SetNWInt("timer", self.time.delay);
		self:Createbarricade();
		if (self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
			self.Owner:RemoveAmmo(1, self.Primary.Ammo);
		elseif (self.Owner:GetAmmoCount(self.Primary.Ammo) == 0) then
			self.Owner:ConCommand("lastinv");
		end
		self.Owner:SetNWInt( "barricade", self.Owner:GetAmmoCount(self.Primary.Ammo));
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		local trace = self.Owner:GetEyeTrace();
		if (trace.HitPos:Distance(self.Owner:GetPos()) < self.Distance and IsValid(trace.Entity) and trace.Entity:GetClass() == "barricade" and self.Owner == trace.Entity:GetNWEntity("owner", {})) then
			self.Owner:GiveAmmo(1, self.Primary.Ammo);
			trace.Entity:Remove();
			self.Owner:SetNWInt( "barricade", self.Owner:GetAmmoCount(self.Primary.Ammo));
		end
	end
	return false;
end

function SWEP:Initialize()
	if SERVER then
		self:SetHoldType( self.HoldType );
	end
	if CLIENT then
		self.modelbarricade = ClientsideModel("models/zombieplague/zp_conus.mdl", RENDERGROUP_TRANSLUCENT);
		self.modelbarricade:SetNoDraw( true );
	end
end

function SWEP:OnRemove()
	if CLIENT then
		self.modelbarricade:Remove();
	end
end

function SWEP:Deploy()
	self.Owner:SetAmmo( self.Owner:GetNWInt( "barricade", 1 ), self.Primary.Ammo );
	if (self.Owner:GetAmmoCount(self.Primary.Ammo) > SHOP.items.barricade.limit) then
		self.Owner:SetAmmo( SHOP.items.barricade.limit, self.Primary.Ammo );
		self.Owner:SetNWInt( "barricade", SHOP.items.barricade.limit )
	end
	if ( CLIENT and IsValid(self.modelbarricade) and self.modellaser != NULL ) then
		self.modelbarricade:SetNoDraw( true );
	end
end

function SWEP:Holster( wep )
	if ( CLIENT and IsValid(self.modelbarricade) and self.modellaser != NULL) then
		self.modelbarricade:SetNoDraw( true );
	end
	return true;
end

function SWEP:Reload()
	return false;
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
	if (CLIENT) then
		if ( !IsValid( self.modelbarricade ) ) then
			self.modelbarricade = ClientsideModel("models/zombieplague/zp_conus.mdl", RENDERGROUP_TRANSLUCENT);
		end
		if (self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
			local trace = LocalPlayer():GetEyeTrace();
			if ( IsValid(trace.Entity) and !IsEmpty(trace.Entity) and trace.Entity:GetClass() == "barricade" ) then 
				self.modelbarricade:SetNoDraw( true );
				return;
			end
			if ( trace and trace.HitPos:Distance(LocalPlayer():GetPos()) < self.Distance ) then
				self.modelbarricade:SetPos( trace.HitPos );
				self.modelbarricade:SetAngles( trace.HitNormal:Angle() );
				self.modelbarricade:SetNoDraw( false );
				return;
			end
			self.modelbarricade:SetNoDraw( true );
		else
			self.modelbarricade:SetNoDraw( true );
		end
	end
end


function SWEP:Createbarricade()
	if (SERVER and IsValid( self.Owner ) and self:CanCreate()) then
		local barricade = ents.Create("barricade");
		local trace = self.Owner:GetEyeTrace();
		barricade:SetPos( trace.HitPos );
		barricade:SetAngles( trace.HitNormal:Angle() );
		barricade.Inflictor = self.Weapon;
		barricade:Spawn();
		barricade:SetNWInt( "team", self.Owner:Team() );
		barricade:SetNWEntity( "owner", self.Owner );
	end
	if CLIENT then
		self.modelbarricade:SetNoDraw( true );
	end
end

function SWEP:CanCreate()
	local trace = self.Owner:GetEyeTrace();
	if (self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then return false end
	if (!IsEmpty(trace.Entity) and trace.Entity:GetClass() == "barricade") then return false end
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

ENT.Type = "anim";
ENT.Base = "base_anim";
ENT.Team = 1;
ENT.Scaled = false;
ENT.RenderGroup = RENDERGROUP_BOTH;
if CLIENT then
   function ENT:DrawTranslucent()
		self:Draw(32);
	end
	function ENT:Draw()
		if (self:GetOwner() == LocalPlayer()) then

		end
		self:DrawModel();
		if (LocalPlayer():GetPos():Distance(self:GetPos()) > 200) then return end
		local owner = self:GetNWEntity( "owner", {} );
		if (!IsValid(owner) or IsEmpty(owner)) then return end
		local ang = LocalPlayer():EyeAngles() + Angle(0,-90,0);
		local pos = self:GetPos() + Vector( 0, 0, 36 ) + ang:Up();
		local colortext = GetTeamColor( owner:Team() ).team;
		local health = self:Health();
		local procent = health / (self:GetMaxHealth() / 100);
		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.05 )
			for i=1,10 do
				local colorline = ColorAlpha(color().gray, 100);
				if (i <= math.ceil(procent / 10)) then colorline = ColorAlpha(color().red, 200); end
				draw.DrawText( "-", "Number", (20 * i) - 110, 30, colorline, TEXT_ALIGN_CENTER );
			end
			draw.DrawText( health.." / "..self.MaxHealth, "NumberBlur", 0, 0, ColorAlpha( colortext, 255 ), TEXT_ALIGN_CENTER );
			draw.DrawText( health.." / "..self.MaxHealth, "Number", 0, 0, ColorAlpha( colortext, 255 ), TEXT_ALIGN_CENTER );
			draw.DrawText( owner:GetName() or "", "NumberMini", 0, 70, ColorAlpha( colortext, 255 ), TEXT_ALIGN_CENTER );
		cam.End3D2D()
	end
end

if SERVER then

	function ENT:Initialize()
		self:SetModel("models/zombieplague/zp_conus.mdl");
		self:SetUseType( SIMPLE_USE );
		self:SetSolid( SOLID_VPHYSICS );
		self:SetMoveType( MOVETYPE_NONE );
		self:DrawShadow(false);
		self:SetMaxHealth( self.MaxHealth );
		self:SetHealth( self.MaxHealth );
		self.WhirrSound = CreateSound(self, "weapons/physcannon/energy_bounce1.wav");
		self.WhirrSound:PlayEx( 0.5, 255 );
	end


	function ENT:OnRemove()
		if (!IsEmpty(self.WhirrSound)) then self.WhirrSound:Stop(); end
	end

	function ENT:Think()
		if (self:GetRenderMode() == 32) then
			local plytrace = ents.FindInBox( self:GetPos() - Vector(20,20,20), self:GetPos() + Vector(20,20,20) );
			local resetbarricade = true;
			for k,v in pairs(plytrace) do
				if (v:IsPlayer() and v == self.Owner) then resetbarricade = false; end
			end
			if ( resetbarricade ) then
				self:SetRenderMode( 1 );
				self:SetOwner( NULL );
				self:SetColor( Color(255, 255, 255, 255) );
			end
		end
	end
	function ENT:Touch( ply )
		if (IsValid(ply) and ply:IsPlayer() and ply:KeyDown( IN_WALK ) and ply:Team() == self:GetNWInt("team", 0) ) then
			self:SetOwner( ply );
			self:SetRenderMode( 32 );
			self:SetColor( Color(255, 255, 255, 50) );
		end
	end


	function ENT:Use( ply )
		self.Owner = self:GetNWEntity("owner", {});
		if ( SERVER and ply == self.Owner and ply:KeyDown( IN_WALK ) ) then
			ply:GiveAmmo(1, "ammo_barricade");
			self:Remove();
			self.Owner:SetNWInt( "barricade", ply:GetAmmoCount("ammo_barricade"));
		end
	end


	function ENT:OnTakeDamage( dmginfo )
		local owner = self:GetNWEntity("owner", {});
		if ( !IsValid(owner) or IsEmpty(owner) or !owner:IsPlayer() ) then 
			self:Remove();
			return;
		end
		if ( dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():Team() == owner:Team() and dmginfo:GetAttacker() != owner ) then return end
		local health = self:Health() - math.ceil(dmginfo:GetDamage() / 10);
		self:SetHealth( health );
		if ( health <= 0 ) then
			local fx = EffectData();
			fx:SetOrigin( self:GetPos() );
			util.Effect("cball_explode", fx);
			self:EmitSound("weapons/rpg/shotdown.wav", 90, 85);
			self:Remove();
		end
	end
end

scripted_ents.Register(ENT, "barricade", true);



