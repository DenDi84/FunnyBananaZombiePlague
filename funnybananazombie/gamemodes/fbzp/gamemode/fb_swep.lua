AddCSLuaFile();

game.AddAmmoType({name = "grenade_jump", dmgtype = DMG_BULLET, tracer = TRACER_LINE, plydmg = 0, npcdmg = 0, force = 2000, minsplash = 10, maxsplash = 5 });
game.AddAmmoType({name = "grenade_fire", dmgtype = DMG_BULLET, tracer = TRACER_LINE, plydmg = 0, npcdmg = 0, force = 2000, minsplash = 10, maxsplash = 5 });
game.AddAmmoType({name = "grenade_light", dmgtype = DMG_BULLET, tracer = TRACER_LINE, plydmg = 0, npcdmg = 0, force = 2000, minsplash = 10, maxsplash = 5 });
game.AddAmmoType({name = "grenade_antidote", dmgtype = DMG_BULLET, tracer = TRACER_LINE, plydmg = 0, npcdmg = 0, force = 2000, minsplash = 10, maxsplash = 5 });

SWEPSOUND = {};
function SWEPSOUND:Create(tbl, name)
	local swepsnd = {
		channel = CHAN_WEAPON,
		volume = 1,
		pitch = 92,
		soundlevel = SNDLVL_GUNFIRE
	};
	for k,v in pairs(tbl) do swepsnd[k] = v; end
	swepsnd.name = name;
	sound.Add(swepsnd);
	util.PrecacheSound( swepsnd.name );
end
function SWEPSOUND:List( tbl, prefix )
	for k,v in pairs(tbl) do
		self:Create(v, prefix.."."..k);
	end
end

local function GrenadeDrop(swep, speed)
	swep:SendWeaponAnim(ACT_VM_SECONDARYATTACK);
	swep.Owner:SetAnimation(PLAYER_ATTACK1);
	if (SERVER) then
		if (swep:GetNextPrimaryFire() > CurTime()) then return false; end
		swep:SetNextPrimaryFire( CurTime() + swep.Primary.Delay );
		if ( swep.Owner:GetAmmoCount( swep.Primary.Ammo ) <= 0) then
			swep.Owner:StripWeapon(swep:GetClass());
			return false;
		end
		swep.Owner:RemoveAmmo(1, swep.Primary.Ammo);
		local shell = ents.Create("fb_grenade");
		shell.Owner = swep.Owner;
		shell.Grenade = swep.Grenade;
		shell.Inflictor = swep.Weapon;
		shell:SetModel(swep.WorldModel);
		shell:SetOwner( swep.Owner );

		local eyeang = swep.Owner:GetAimVector():Angle();
		shell:SetPos(swep.Owner:GetShootPos() + eyeang:Right() * 4 + eyeang:Up() * 4);
		shell:SetAngles(swep.Owner:GetAngles());
		shell:SetPhysicsAttacker(swep.Owner);
		shell:Spawn();
		shell:Activate();

		shell:EmitSound("zombie_swing");
		local phys = shell:GetPhysicsObject();
		phys:SetVelocity(swep.Owner:GetAimVector() * speed + (swep.Owner:GetVelocity() * 0.75));
	end
	swep.Owner:SetAnimation( PLAYER_ATTACK1 );
	swep:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
end

ZPWEAPON = {};
ZPWEAPON.Default = {
	Author = "FunnyBanana",
	Base = "weapon_base",
	m_WeaponDeploySpeed = 1, -- Множитель "доставания" оружия
	WorldModel = "",
	ViewModel = "",
	ViewModelFlip = false, -- Отзеркалить модель
	ViewModelFOV = 70, -- Приближение вида оружия
	HoldType = "ar2", -- Как держать оружие
	AutoSwitchFrom = false, -- Автоматически переключаться на это оружие при поднятии другого оружия
	AutoSwitchTo = false, -- Автоматически переключаться на это оружие если поднимаешь его с пола
	UseHands = true, -- Использовать стандартную модель рук
	Weight = 0, -- Вес по которому определяется качество оружия?
	Tracer = true,
	NextAnimateTime = 0, -- Следующее время анимации
	Primary = {
		Sound = Sound("Weapon_Ar2.Single"), -- Звук при выстреле.
		Damage = 10, -- Скокльо урона наносит оружие
		TakeAmmo = 1, -- Сколько патронов тратится при выстреле
		ClipSize = 100, -- Размер обоймы
		Ammo = "Pistol", -- Тип патронов
		DefaultClip = 0, -- Сколько патронов в оружии по умолчанию
		Spread = 0.1, -- Разброс
		NumberofShots = 1, -- Сколько выстрелов делается при выстреле?
		Automatic = true, -- Можно зажать?
		Recoil = 1, -- Отдача
		Delay = .1, -- Задержка при выстреле
		Force = 0, -- Сила выстрела
	},
	Secondary = {
		Sound = Sound("Weapon_Ar2.Single"), -- Звук при выстреле.
		Damage = 10, -- Скокльо урона наносит оружие
		TakeAmmo = 1, -- Сколько патронов тратится при выстреле
		ClipSize = 100, -- Размер обоймы
		Ammo = "Pistol", -- Тип патронов
		DefaultClip = 100, -- Скокльо патронов в оружии по умолчанию
		Spread = 0.1, -- Разброс
		NumberofShots = 1, -- Сколько выстрелов делается при выстреле?
		Automatic = false, -- Можно зажать?
		Recoil = 10, -- Отдача
		Delay = 3, -- Задержка при выстреле
		Force = 0, -- Сила выстрела
	},
	BobScale = 1.0, -- увеличение view модели
	BounceWeaponIcon = false, -- иконка подпрыгивает при выборе оружия
	DrawAmmo = false, -- рисовать аммо или нет
	DrawCrosshair = true, -- рисовать прицел или нет
	DrawWeaponInfoBox = false, -- рисовать справку об оружии
	PrintName = "Zombie Weapons", -- название оружия в меню выбора 
	Slot = 0, -- слот
	SlotPos = 0, -- сортировка в слоте
	SwayScale = 1.0, -- уровень колебания оружия
	CSMuzzleFlashes = true, -- вспышка при выстреле
	SimpleZoom = 100, -- увеличение FOV при нажатии на ПКМ
	DrawFake = false, -- Рисует фейковую мировую модель
	WorldModelOffset = { pos = Vector(0,0,0), ang = Angle(0,0,0) },
	BounceWeaponIcon = false,
	Grenade = {
		ExplodeOnCollide = false, -- Взрыв при касании пола
		ExplodeOnTouch = false, -- Взрыв при касании энтити
		ExplodeRadius = 100, -- Радиус поражения взрывом
		ExplodeSound = "zombie_explode", -- Звук взрыва
		ExplodeDelay = 2 -- Задержка перед взрывом
	},
	Initialize = function( self )
		self:SetHoldType( self.HoldType );
		self:SetWeaponHoldType( self.HoldType );
		if ( self.DrawFake and CLIENT ) then
			self.FakeWorldModel = ClientsideModel(self.WorldModel);
			self.FakeWorldModel:SetNoDraw(true);
		end
	end,
	StandartAttack = function( self )
		local bullet = {} 
		bullet.Num = self.Primary.NumberofShots;
		bullet.Src = self.Owner:GetShootPos();
		bullet.Dir = self.Owner:GetAimVector();
		bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0);
		bullet.Tracer = self.Tracer;
		bullet.Force = self.Primary.Force;
		bullet.Damage = self.Primary.Damage;
		bullet.AmmoType = self.Primary.Ammo;
		local rnda = self.Primary.Recoil * -1; 
		local rndb = self.Primary.Recoil * math.random(-1, 1);
		self:ShootEffects();
		self.Owner:FireBullets( bullet );
		self:EmitSound(Sound(self.Primary.Sound));
		self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) );
		self:TakePrimaryAmmo(self.Primary.TakeAmmo);
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
		self:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

		local fx = EffectData();
		fx:SetOrigin(self:GetPos());
		util.Effect("tfa_shell_legacy", fx);

	end,
	PrimaryAttack = function( self ) -- Первичная атака
		if ( !self:CanPrimaryAttack() ) then return end
		self:StandartAttack();
	end,
	SecondaryAttack = function( self ) -- Альтернативная атака ПКМ
		return; 
	end,
	Reload = function( self ) 
		if (self.ReloadingTime and CurTime() <= self.ReloadingTime) then return end
		if ( self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
			self:DefaultReload( ACT_VM_RELOAD );
			local AnimationTime = self.Owner:GetViewModel():SequenceDuration();
			self.ReloadingTime = CurTime() + AnimationTime;
			self:SetNextPrimaryFire(CurTime() + AnimationTime);
			self:SetNextSecondaryFire(CurTime() + AnimationTime);
		end
	end,
	Think = function( self ) -- Каждый тик
		
	end,
	GrenadeThink = function ( self )
		if ( self.NextAnimateTime > CurTime() ) then
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
		elseif ( self.Owner:KeyDown(IN_ATTACK) and self.NextAnimateTime < CurTime() and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
			self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK);
			self.Owner:SetAnimation(PLAYER_ATTACK1);
			self.NextAnimateTime = CurTime() + self.Primary.Delay + self.Grenade.ExplodeDelay;
		end
	end,
	Holster = function( self ) -- Когда убираем оружие в кобуру.
		if (CLIENT and IsValid(self.Owner)) then
			self:SetWeaponHoldType( self.HoldType );
			local vm = self.Owner:GetViewModel();
			if IsValid(vm) then
				self:ResetBonePositions(vm);
			end
		else
			self:SetHoldType( self.HoldType );
		end
		return true;
	end,
	Deploy = function( self ) -- Достаём оружие
			local vm = self.Owner:GetViewModel();
			if IsValid(vm) then
				self:ResetBonePositions(vm);
			end
		if (CLIENT and IsValid(self.Owner)) then
			self:SetWeaponHoldType( self.HoldType );
		else
			self:SetHoldType( self.HoldType );
		end
	end,
	Equip = function( self, NewOwner )
		if (CLIENT and IsValid(self.Owner)) then
			self:SetWeaponHoldType( self.HoldType );
		else
			self:SetHoldType( self.HoldType );
		end
	end,
	ShootEffects = function( self ) -- Эффект выстрела
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
		self.Owner:MuzzleFlash();
		self.Owner:SetAnimation( PLAYER_ATTACK1 );
	end,
	CanPrimaryAttack = function( self ) -- Возможность стрелять
		if ( self.Weapon:Clip1() <= 0) then
			self:EmitSound( "Weapon_Pistol.Empty" );
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
			self:Reload();
			return false;
		end
		return true;
	end,
	TranslateFOV = function( self ) -- Увеличение вида от первого лица
		if (self.Owner:KeyDown( IN_ATTACK2 )) then
			return self.Owner:GetFOV() / 100 * self.SimpleZoom;
		else
			return self.Owner:GetFOV();
			-- return self.ViewModelFOV;
		end
	end,
	AdjustMouseSensitivity = function( self ) -- Уменьшение чувствительности мыши
		if ( self.Owner:KeyDown( IN_ATTACK2 ) and self.SimpleZoom != 100) then
			return 0.2;
		end
		return 1;
	end,
	ResetBonePositions = function( vm ) -- Сброс позиций костей рук.
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) );
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) );
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) );
		end
	end,
	GrenadeExplode = function( self, pos ) -- Взрыв гранаты
		print(pos);
	end,
	ShouldDropOnDie = function( self )
		return false;
	end,
	GetViewModelPosition = function ( self, pos, ang )
		return pos, ang;
	end,
	DrawWorldModel = function( self )
		if (self.DrawFake) then
			local owner = self:GetOwner();
			if (IsValid(owner)) then
				local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand");
				if (!boneid) then return; end
				local matrix = owner:GetBoneMatrix( boneid );
				if (!matrix) then return; end
				local newPos, newAng = LocalToWorld( self.WorldModelOffset.pos, self.WorldModelOffset.ang, matrix:GetTranslation(), matrix:GetAngles() );
				self.FakeWorldModel:SetPos( newPos );
				self.FakeWorldModel:SetAngles( newAng );
	            self.FakeWorldModel:SetupBones();
	            self.FakeWorldModel:DrawModel();
			end
		else
			self:DrawModel();
			return true;
		end
	end,
	PreDrawViewModel = function ( self, vm, weapon, ply )
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) );
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) );
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) );
			if (i < 0) then
				vm:ManipulateBoneScale( i, Vector(0, 0, 0) );
			end
		end
	end
};

function ZPWEAPON:Init()
	weapons.Register( self.Default, "zombie_swep" );
end
function ZPWEAPON:Create( table, class_name )
	local swep = weapons.Get( "zombie_swep" );
	for k,v in pairs(table) do
		if ( istable( v ) ) then
			for kk,vv in pairs(v) do 
				swep[k][kk] = vv; 
			end
		else
			swep[k] = v; 
		end
	end
	weapons.Register( swep, class_name );
	print("Weapons: "..class_name.." create!");
	return weapons.GetStored( class_name );
end

ZPWEAPON:Init();

SERVERWEAPONS = {
	zweapon_vip_p2011sp = {
		SWEP = {
			PrintName = "P2011SP",
			ViewModelFOV = 75,
			HoldType = "pistol",
			Slot = 1,
			SlotPos = 0,
			Primary = {
				Sound = Sound("zweapon_vip_p2011sp.fire"),
				ClipSize = 12,
				DefaultClip = 12,
				Damage = 15,
				Automatic = false,
				Ammo = "pistol"
			},
			ViewModel = "models/weapons/tfa_titanfall/c_p2011sp.mdl",
			WorldModel = "models/weapons/tfa_titanfall/w_p2011sp.mdl"
		},
		SOUND = SWEPSOUND:List({
			fire = {
				sound = "weapons/smartpistol/wpn_smartpistol_1p_wpnfire_core_6ch_v1_01.wav"
			}
		}, "zweapon_vip_p2011sp")
	},
	zweapon_vip_car101 = {
		SWEP = {
			PrintName = "R101 Carbine",
			ViewModelFOV = 75,
			HoldType = "ar2",
			Primary = {
				Sound = Sound("zweapon_vip_car101.fire"),
				ClipSize = 100,
				Damage = 75,
				DefaultClip = 100,
				Ammo = "ar2"
			},
			ViewModel = "models/weapons/tfa_tf/c_car101.mdl",
			WorldModel = "models/weapons/tfa_tf/w_car101.mdl"
		},
		SOUND = SWEPSOUND:List({
			fire = {
				sound = "weapons/cbr101/wpn_cbr101_1p_wpnfire_firstshot_core_6ch_v2_01.wav"
			}
		}, "zweapon_vip_car101")
	},
	zweapon_vip_hemlok = {
		SWEP = {
			PrintName = "Hemlok",
			ViewModelFOV = 80,
			HoldType = "ar2",
			Slot = 0,
			SlotPos = 0,
			CSMuzzleFlashes = true,
			DrawFake = false,
			Primary = {
				Sound = Sound("zweapon_vip_hemlok.fire"),
				Damage = 20,
				ClipSize = 30,
				DefaultClip = 30,
				Spread = 0.2,
				Recoil = .5,
				Ammo = "ar2"
			},
			ViewModel = "models/weapons/tfa_tf/c_hemlok.mdl",
			WorldModel = "models/weapons/tfa_tf/w_hemlok.mdl",
			SimpleZoom = 80
		},
		SOUND = SWEPSOUND:List({
			fire = {
				sound = "weapons/Hemlok/wpn_hemlok_1p_wpnfire_core_3shotburst_6ch_v1_02.wav"
			}
		}, "zweapon_vip_hemlok")
	},
	light_grenade = {
		SWEP = {
			PrintName = "Light Grenade",
			ViewModelFOV = 75,
			HoldType = "grenade",
			Slot = 3,
			SlotPos = 2,
			CSMuzzleFlashes = false,
			DrawFake = true,
			WorldModelOffset = { 
				pos = Vector(4,-1.5,0), 
				ang = Angle(0,0,0) 
			},
			Primary = {
				ClipSize = 10,
				DefaultClip = -1,
				Delay = 1,
				Ammo = "grenade_light"
			},
			ViewModel = "models/weapons/yurie_rustalpha/c-vm-flare.mdl",
			WorldModel = "models/weapons/yurie_rustalpha/wm-flare.mdl",
			SimpleZoom = 100,
			PrimaryAttack = function(self)
				GrenadeDrop(self, 1000);
			end,
			SecondaryAttack = function(self)
				GrenadeDrop(self, 100);
			end,
			Grenade = {
				ExplodeRadius = 400,
				ExplodeOnCollide = false,
				ExplodeOnTouch = false,
				ExplodeSound = "zombie_light_on",
				ExplodeDelay = 2
			},
			GrenadeExplode = function(self, pos, angle)
				local light = ents.Create("fb_light");
				light:SetPos(pos);
				light:SetAngles(angle);
				light:Spawn();
				light:Activate();
			end
		}
	},
	jump = {
		SWEP = {
			PrintName = "Jump Grenade",
			ViewModelFOV = 75,
			HoldType = "grenade",
			Slot = 3,
			SlotPos = 2,
			CSMuzzleFlashes = false,
			Primary = {
				ClipSize = 10,
				DefaultClip = -1,
				Delay = 1,
				Ammo = "grenade_jump"
			},
			ViewModel = "models/weapons/c_bugbait.mdl",
			WorldModel = "models/weapons/w_bugbait.mdl",
			SimpleZoom = 100,
			PrimaryAttack = function(self)
				GrenadeDrop(self, 1000);
			end,
			SecondaryAttack = function( self )
				GrenadeDrop(self, 100);
			end,
			Think = function( self )
				self.GrenadeThink( self );
			end,
			Grenade = {
				ExplodeRadius = 300,
				ExplodeOnCollide = true,
				ExplodeOnTouch = true,
				ExplodeSound = "zombie_jump"
			},
			GrenadeExplode = function(self, pos)
				for k,v in pairs(ents.FindInSphere( pos, self.Grenade.ExplodeRadius )) do
					if (v:IsPlayer() or v:IsNPC()) then
						local playerpos = v:GetPos();
						local coef = pos:Distance(playerpos) / (self.Grenade.ExplodeRadius / 100); -- Процентное соотношение дистанции.
						local offset = { x = .05, y = .05 };
						if (pos.x > playerpos.x) then offset.x = -.05; end
						if (pos.y > pos.y) then offset.y = -.05; end
						v:SetVelocity( Vector(offset.x * coef,offset.y * coef,2.5) * ((100 - coef) * 3) + VectorRand()*80 );
					end
				end
			end
		}
	},
	fire = {
		SWEP = {
			PrintName = "Fire Grenade",
			ViewModelFOV = 75,
			HoldType = "grenade",
			Slot = 3,
			SlotPos = 1,
			CSMuzzleFlashes = false,
			Primary = {
				ClipSize = 10,
				DefaultClip = -1,
				Delay = 1,
				Ammo = "grenade_fire"
			},
			ViewModel = "models/weapons/tfa_st5/c_st5_red.mdl",
			WorldModel = "models/weapons/tfa_st5/w_st5_red.mdl",
			SimpleZoom = 100,
			PrimaryAttack = function(self)
				GrenadeDrop(self, 1000);
			end,
			SecondaryAttack = function( self )
				GrenadeDrop(self, 100);
			end,
			Think = function( self )
				self.GrenadeThink( self );
			end,
			Grenade = {
				ExplodeRadius = 300,
				ExplodeOnCollide = false,
				ExplodeOnTouch = false,
				ExplodeSound = false
			},
			GrenadeExplode = function(self, pos)
				local fx = EffectData();
				fx:SetOrigin(pos + Vector(0,0,5));
				util.Effect("Explosion", fx, true, true);
				for k,v in pairs(ents.FindInSphere( pos, self.Grenade.ExplodeRadius )) do
					if (v:IsPlayer()) then
						if (v:Team() == 2) then
							local playerpos = v:GetPos();
							local damage = self.Grenade.ExplodeRadius - pos:Distance(playerpos);
							v:TakeDamage( damage, self, self );
							v:Ignite( 10, 10 );
						end
					else
						if (v:GetClass() != "fb_grenade") then
							v:TakeDamage( 150, self, self );
						end
					end
				end
			end
		}
	},
	antidote = {
		SWEP = {
			PrintName = "Antidote Grenade",
			ViewModelFOV = 75,
			HoldType = "grenade",
			Slot = 3,
			SlotPos = 1,
			CSMuzzleFlashes = false,
			Primary = {
				ClipSize = 10,
				DefaultClip = -1,
				Delay = 1,
				Ammo = "grenade_antidote"
			},
			ViewModel = "models/weapons/tfa_st5/c_st5_green.mdl",
			WorldModel = "models/weapons/tfa_st5/w_st5_yellow.mdl",
			SimpleZoom = 100,
			PrimaryAttack = function(self)
				GrenadeDrop(self, 1000);
			end,
			SecondaryAttack = function( self )
				GrenadeDrop(self, 100);
			end,
			Think = function( self )
				self.GrenadeThink( self );
			end,
			Grenade = {
				ExplodeRadius = 300,
				ExplodeOnCollide = false,
				ExplodeOnTouch = false,
				ExplodeSound = "zombie_explode"
			},
			GrenadeExplode = function(self, pos)
				local fx = EffectData()
				fx:SetOrigin(pos + Vector(0,0,5))
				util.Effect("explode_health", fx);
				for k,v in pairs(ents.FindInSphere( pos, self.Grenade.ExplodeRadius )) do
					if (v:IsPlayer()) then
						if (v:IsPlayer() and v:Team() == 2 and GetAlive().zombie > 1) then
							self.Owner:AddMoney( 50 );
							v:SetHuman();
						end
					end
				end
			end
		}
	}
};

if (CLIENT) then
	SERVERWEAPONS.fire.SWEP.WepSelectIcon = surface.GetTextureID( "icons/swep/fire" );
	SERVERWEAPONS.jump.SWEP.WepSelectIcon = surface.GetTextureID( "icons/swep/fire" );
	SERVERWEAPONS.light_grenade.SWEP.WepSelectIcon = surface.GetTextureID( "icons/swep/light" );
	SERVERWEAPONS.zweapon_vip_hemlok.SWEP.WepSelectIcon = surface.GetTextureID( "icons/swep/hem" );
	SERVERWEAPONS.zweapon_vip_car101.SWEP.WepSelectIcon = surface.GetTextureID( "icons/swep/hem" );
	SERVERWEAPONS.zweapon_vip_p2011sp.SWEP.WepSelectIcon = surface.GetTextureID( "icons/swep/pist" );
	-- ZPWEAPON.Default.WepSelectIcon = surface.GetTextureID( "icons/swep/knife" );
	-- print("fb_swep");
end


for k,v in pairs(SERVERWEAPONS) do
	ZPWEAPON:Create(v.SWEP, k);
end