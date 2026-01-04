local PLAYER = FindMetaTable( "Player" );

PrecacheParticleSystem( "Rocket_Smoke" );

PLAYER.firstperson = true;
PLAYER.time = {
	firstperson = 0,
	freeze = 0,
	SpecAttack = {},
};

-- Игрок заспавнился:
function PLAYER:OnSpawn()
	local point
	local spawnpoint
	PrintTable(MAP.spawnpoint)
	if MAP.spawnpoint and #MAP.spawnpoint > 0 then
        local randomIndex = math.random(1, #MAP.spawnpoint)
		print('randomIndex= '.. randomIndex)
        point = MAP.spawnpoint[randomIndex]
		print(point)
		spawnpoint = FindPointToSpawn( point, 4 );
    else
        -- Возвращаем какую-то точку по умолчанию, если таблица пуста или не найдена
        point = Vector(0, 0, 0)
    end
	if spawnpoint then
		self:SetPos( spawnpoint );
	else 
		self:SetPos( point );
	end
	self:GetAvatar();
	self:ChoiseClass();
end

-- Получаем данные игрока:
function PLAYER:GetPlayerInfo()
	if ( !self:GetNWBool("auth", false) ) then return false; end
	local result = {
		money = self:GetNWInt("money", 0),
		exp = self:GetNWInt("exp", 0),
		registration = self:GetNWString("registration", 0),
		avatar = self:GetNWString("avatar", "")
	};
	return result;
end
-- Записываем в сетевые переменные данные игрока:
function PLAYER:SetPlayerInfo( data )
	self:SetNWInt("money", data.money);
	self:SetNWInt("exp", data.exp);
	self:SetNWString("registration", data.registration);
	self:SetNWBool("auth", true);
	self:SetNWBool("firstperson", false);
	self:SetNWString("votemap", "");
	self:SetNWInt("lasermine", 1);
	self:SetNWInt("barricade", 1);
end
-- Получаем данные игрока из БД:
--[[function PLAYER:GetUserDataFromDB( result )
	databaseObject:setCharacterSet('utf8');
	local steamid = self:SteamID64();
	if (self:IsBot()) then
		steamid = "90071996842377216";
	end
	local query = databaseObject:query("SELECT * FROM `users` WHERE `SteamID64` = '"..steamid.."'");
	query.onSuccess = function(q) 
		local list = q:getData();
		if (list[1] == nil) then 
			result( false ); 
		else
			result( list[1] );
		end
	end
	query.onError = function(q,e) 
		self:Abort( 'error GetUserDataFromDB', e ); 
	end
	query:start();
end--]]
-- Создаём игрока:
function PLAYER:CreatePlayer(result)
	databaseObject:setCharacterSet('utf8');
	local player_name = string.Replace(self:GetName(), "'", "\'");
	local query = databaseObject:query("INSERT INTO `users` (`SteamID`, `name`, `SteamID64`) VALUES ('" .. self:SteamID() .. "', '" .. player_name .. "', '" .. self:SteamID64() .. "')");
	query.onSuccess = function(q) 
		result(true);
	end
	query.onError = function(q,e) 
		self:Abort( 'error CreatePlayer', e ); 
	end
	query:start();
end
-- Записываем в лог дату входа
function PLAYER:Log( type, frags )
	frags = frags or 0;
	if (self:IsBot()) then return false; end
	databaseObject:query("INSERT INTO `stats` (`SteamID64`, `type`, `frags`, `server`) VALUES ('"..self:SteamID64().."', '"..type.."', '"..frags.."', '"..CFG.ServerNum.."')"):start();
end
-- Записываем в лог дату входа
--[[function PLAYER:LogKill( attacker, target, team )
	if (player.GetBySteamID64( target ):IsBot()) then return false; end
	databaseObject:query("INSERT INTO `stats_kill` (`owner`, `target`, `target_team`, `server`) VALUES ('"..attacker.."', '"..target.."', '"..team.."', '"..CFG.ServerNum.."')"):start();
end--]]

function PLAYER:Loadout()
	return false;
end
-- Установка оружия по умолчанию
function PLAYER:SetWeaponDefault(weapontype, weaponname)
	if (weapontype == "primary") then
		self:SetNWString("swep_primary", weaponname);
	end
	if (weapontype == "secondary") then
		self:SetNWString("swep_secondary", weaponname);
	end
end


-- Кикаем игрока в случае ошибки
function PLAYER:Abort( reason, log )
	echo( log );
	self:Kick( reason );
end
-- Смерть игрока
function PLAYER:OnDeath(attacker, inflictor)
	-- Оповещаем о том что список игроков в командах изменился.
	TeamCountChange();

	self:Freeze( true );
	timer.Simple( 5, function()
		if (IsValid(self) and !self:Alive()) then self:Spawn(); end
	end );
end
-- Смерть игрока при смене раунда или команды
function PLAYER:OnDeathSilent()

end

function PLAYER:GetType()
	local model = self:GetModel();
	for k,v in pairs(self.models) do
		if (v.model == model) then
			return k;
		end
	end
	return false;
end

function PLAYER:SetHuman()
	local modelname = "isa_sniper";

	if (self:SteamID64() == "76561198393560436") then
		modelname = "moira";
	end

	self:SetModel( self.models[modelname].model );

	self:SetBodyGroups( self.models[modelname].getBodyGroups() );
	self:PreSet( self.models[modelname].health, 1, self.models[modelname].speed );
	self:SetupHands();
	self:Give("zp_knife");

	self:Give("zp_freeze");
	self:GiveAmmo( 1, "freeze_grenade", true );

	self:Give("fire");
	self:GiveAmmo( 1, "grenade_fire", true );

	-- self:Give("zweapon_vip_p2011sp");
	-- self:GiveAmmo( 72, "pistol", true );

	-- self:Give("zweapon_vip_hemlok");
	-- self:GiveAmmo( 240, "ar2", true );

	self:Give( "light_grenade" );
	self:GiveAmmo( 1, "grenade_light", true );

	self:Give( self:GetNWString("swep_primary", "weapon_l4d1_smgsilenced"));
	self:Give( self:GetNWString("swep_secondary", "weapon_l4d1_pistol"));

	self:SelectWeapon("zp_knife");

	self:AllowFlashlight( true );
end

function PLAYER:SetNemesida()
	local modelname = "demogorgon";
	self:SetModel( self.models[modelname].model );
	self:SetBodyGroups( self.models[modelname].getBodyGroups() );
	self:PreSet( self.models[modelname].health() , 2, self.models[modelname].speed );
	self:SetupHands();
	self:AllowFlashlight( false );
	self:SetJumpPower( 450 );
	self:StripWeapons();
	self:Give("zp_nemesida");
	self:ScreenFade( SCREENFADE.IN, ColorAlpha( color().red, 128 ), 0.3, 0.3 );
	self:SetBloodColor( BLOOD_COLOR_ZOMBIE );
end

function PLAYER:SetHero()
	local modelname = "ё";
	self:SetModel( self.models[modelname].model );
	self:SetBodyGroups( self.models[modelname].getBodyGroups() );
	self:PreSet( self.models[modelname].health() , 1, self.models[modelname].speed );
	self:SetupHands();
	self:AllowFlashlight( true );
	self:SetJumpPower( self.models[modelname].jumpPower );
	self:StripWeapons();

	self:Give("weapon_l4d1_ak47");
	self:GiveAmmo( 10000, "ar2", true );

	self:ScreenFade( SCREENFADE.IN, ColorAlpha( color().blue, 128 ), 0.3, 0.3 );
end

function PLAYER:SetZombie()
	local zombies = {"l4dhunter", "wraith_dbd", "l4dsmoker"};
	local modelname = table.Random( zombies );
	self:SetModel( self.models[modelname].model );
	self:SetBodyGroups( self.models[modelname].getBodyGroups() );
	self:PreSet( self.models[modelname].health, 2, self.models[modelname].speed );
	self:SetupHands();
	self:Give( "zp_knife" );
	self:Give("jump");
	self:GiveAmmo(2, "grenade_jump", true);
	self:ScreenFade( SCREENFADE.IN, ColorAlpha( color().green, 128 ), 0.3, 0.3 );
	self:AllowFlashlight( false );
	self:SetBloodColor( BLOOD_COLOR_ZOMBIE );
	self:SelectWeapon("zp_knife");
	self:SetJumpPower( self.models[modelname].jumpPower );
end

function PLAYER:SetRaven()
	self:PreSet( 10, 3, 10 );
	local raven = ents.Create("raven");
	raven:SetPos( self:GetPos() );
	raven:SetAngles( self:GetAngles() );
	raven:Spawn();
	raven:SetPilot( self );
	raven:Activate();
end

function PLAYER:PreSet( health, team, speed )
	self:ExitVehicle();
	self:UnSpectate();
	self:RemoveFlags( FL_ATCONTROLS );
	self:SetJumpPower( 200 );
	self:StripWeapons();
	self:RemoveAllAmmo();
	self:Freeze( false );
	self:SetHealth( health );
	self:SetMaxHealth( health );
	self:SetTeam( team );
	self:SetMaxSpeed( speed );
	self:SetRunSpeed( speed );
	self:SetWalkSpeed( speed );
	self:SetNoDraw( false );
	self:SetBloodColor( BLOOD_COLOR_RED );
	self:SetColor( Color(255,255,255,255) );
	self:SetGravity( 1 );
	if (self:FlashlightIsOn()) then self:Flashlight( false ); end
	self:GetExtraWeapons();
	self:SetCanZoom( false );
	-- Оповещаем о том что список игроков в командах изменился.
	TeamCountChange();
end

function PLAYER:GetExtraWeapons()
	local lasermine = self:GetNWInt("lasermine", 0);
	local barricade = self:GetNWInt("barricade", 0);
	self:Give("zp_mine");
	self:Give("zp_barricade");
	self:GiveAmmo( lasermine, "mine", true );
	self:GiveAmmo( barricade, "ammo_barricade", true );
end

function PLAYER:Spec()
	self:PreSet(0, 0, 0);
	self:Spectate( OBS_MODE_ROAMING );
end

function PLAYER:ChoiseClass()
	-- self:SetHuman();
	local round_type = zombieplague:GetNWString("round.type", "ready");
	local round_time = zombieplague:GetNWInt("round.time", 0);
	local round_length = zombieplague:GetNWInt("round.length", 0);
	if (self:GetNWBool("spec", false)) then
		self:Spec()
	elseif (#player:GetAll() == 1) then
		self:SetHuman();
	elseif (round_type == "ready") then
		self:SetHuman();
	elseif ( round_type == "escape") then
		self:SetRaven();
	elseif ( round_type == "infection") then
		self:SetRaven();
	elseif ( round_type == "massinfection" ) then
		self:SetZombie();
	elseif ( round_type == "invasion" ) then
		self:SetZombie();
	elseif ( round_type == "demogorg" ) then
		self:SetHuman();
	elseif ( round_type == "hero" ) then
		self:SetZombie();
	else
		self:SetRaven();
	end
end

-- Заморозка игрока
function PLAYER:SetFreeze( time )
	self:AddFlags( FL_ATCONTROLS );
	self:ScreenFade( SCREENFADE.IN, ColorAlpha(color().blue, 150), time, time/20 );
	self:SetColor( color().blue );
	self:SetNWInt("freeze", CurTime() + time);
end

-- Переключение режимов камеры
function PLAYER:ToogleView()
	self:SetNWBool("firstperson", !self:GetNWBool("firstperson", true));
end

function PLAYER:AddMoney( money )
	self:SetNWInt( "money", self:GetNWInt("money", 0) + money );
	self:SetNWInt( "exp", self:GetNWInt("exp", 0) + money );
end
function PLAYER:GetMoney( money )
	return self:GetNWInt("money", 0);
end
function PLAYER:ReduceMoney( money )
	self:SetNWInt( "money", self:GetNWInt("money", 0) - money );
end

function PLAYER:Infect( attacker, inflictor )
	self:AddDeaths( 1 );
	attacker:AddFrags( 1 );
	attacker:AddMoney( 1 );
	SendNotify( {
		type = "infection",
		target = self:GetName(),
		attacker = attacker:GetName(),
		inflictor = "zp_infect",
		time = CurTime(),
		team = {
			attacker = attacker:Team(),
			target = self:Team()
		}
	} );
	self:SetZombie();
end

-- Если игрок застрял:
function PLAYER:Unstuck()
	local tr = {
		start = self:GetPos()-Vector(16,16,0),
		endpos = self:GetPos()+Vector(16,16,36)
	};
	local barrier = ents.FindInBox( tr.start, tr.endpos );
	for k,v in pairs(barrier) do
		if ((IsValid( v ) and v:GetParent() != self and v != self) or util.TraceLine( tr ).HitWorld) then
			local exitpoint = FindPointToSpawn( self:GetPos(), 5 );
			if (exitpoint) then self:SetPos(exitpoint); end
			return;
		end
	end
	timer.Simple( 5, function()
		self:RemoveFlags( FL_ATCONTROLS );
		self:SetColor( Color(255,255,255,255) );
		self:SetRenderMode( RENDERMODE_TRANSALPHA );
	end )
end

-- Скачиваем аватарку игрока:
function PLAYER:GetAvatar()
	if ( IsEmpty(self:SteamID64()) ) then return end
	http.Fetch( "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=6C779DFC66FAA89E684157EA0AF555CC&steamids="..self:SteamID64(), 
		function( body, len, headers, code )
			local jsontable = util.JSONToTable( body );
			if (#jsontable['response']['players'] > 0) then
				self:SetNWString("avatar", jsontable['response']['players'][1]['avatar'] );
			end
		end, 
		function( error ) echo( error ); end
	);
end

function PLAYER:AddHealth( amount, limit )
	local limit = limit or false;
	local maxhealth = self:GetMaxHealth();
	local health = self:Health();
	amount = health + amount;
	if (limit and maxhealth <= health) then
		amount = maxhealth;
	end
	self:SetHealth( amount );
end

function GM:KeyRelease( player, key )
	if ( key == IN_SPEED ) then
		if (player:Team() != 3) then
			local playertype = player:GetType();
			player.models[playertype].SpecAttack( player );
		end
	end
end

PLAYER.models = {
	isa_sniper = {
		model = "models/grim/isa/isa_sniper.mdl",
		hands = "models/grim/isa/isa_sniper_hands.mdl",
		speed = 300,
		health = 100,
		jumpPower = 200,
		getBodyGroups = function( self )
			return "000";
		end,
		SpecAttack = function( self )
			-- self.models.l4dsmoker.SpecAttack( self );
		end
	},
	soap = {
		model = "models/humans/soap.mdl",
		hands = "models/weapons/c_becketarms.mdl",
		speed = 300,
		health = function( self )
			return table.Count( player:GetAll() )*1000;
		end,
		jumpPower = 300,
		getBodyGroups = function( self )
			return "000";
		end,
		SpecAttack = function( self )

		end
	},
	moira = {
		model = "models/mark2580/resident2/moira_prisoner_player.mdl",
		hands = "models/weapons/c_arm_jillbsaa.mdl",
		speed = 300,
		health = 100,
		jumpPower = 200,
		getBodyGroups = function( self )
			return "0000000";
		end,
		SpecAttack = function( self )

		end
	},
	l4dhunter = {
		model = "models/player/pizzaroll/l4dhunter.mdl",
		hands = "models/weapons/l4dhunterarms.mdl",
		speed = 350,
		health = 1000,
		jumpPower = 250,
		getBodyGroups = function( self )
			return "0";
		end,
		SpecAttack = function( self )

		end
	},
	l4dsmoker = {
		model = "models/player/pizzaroll/l4dsmoker.mdl",
		hands = "models/weapons/l4dsmokerarms.mdl",
		speed = 300,
		health = 1500,
		jumpPower = 300,
		getBodyGroups = function( self )
			return "0";
		end,
		SpecAttack = function( ply )
			if (ply.time.SpecAttack[ply.SteamID64] == nil) then
				ply.time.SpecAttack[ply.SteamID64] = 0;
			end
			local length = 0;
			local distance = 1000;
			if (ply.time.SpecAttack[ply.SteamID64] > CurTime()) then return false; end
			local target = ply:GetEyeTrace().Entity;
			if (!target:IsPlayer()) then return false; end
			if (target:GetPos():Distance( ply:GetPos() ) > distance) then return false; end
			ply.time.SpecAttack[ply.SteamID64] = CurTime() + length * 4;
			target:SetVelocity( ply:GetAimVector() * ( distance / 2 ) + VectorRand()*80 );
		end
	},
	wraith_dbd = {
		model = "models/n7legion/deadbydaylight/wraith_hallowedblight_pm.mdl",
		hands = "models/n7legion/deadbydaylight/wraith_hallowedblight_arms.mdl",
		speed = 300,
		health = 1500,
		jumpPower = 200,
		getBodyGroups = function( self )
			return "00";
		end,
		SpecAttack = function( self )
			if (self.time.SpecAttack[self.SteamID64] == nil) then
				self.time.SpecAttack[self.SteamID64] = 0;
			end
			local length = 5;
			local distance = 200;
			if (self.time.SpecAttack[self.SteamID64] > CurTime()) then return false; end
			self.time.SpecAttack[self.SteamID64] = CurTime() + length * 4;
			self:EmitSound("zombie_noise");
			timer.Create( "SpecAttack"..self:SteamID64(), .1, length*10, function()
				for k, v in pairs(ents.FindInSphere( self:GetPos(), 200 )) do
        			if (IsValid(v) and v:IsPlayer() and v:Team() != self:Team()) then
            			if not IsValid(self) then return end 
            			local damage = distance - self:GetPos():Distance( v:GetPos() );
						if SERVER then
            				v:TakeDamage( damage / 100, self, self );
						end
       			 	end
    			end
				local fx = EffectData();
				fx:SetOrigin( self:GetPos() );
				util.Effect("spark_yellow", fx, true, true);
			end );
			timer.Create("StopSpecAttackSound"..self:SteamID64(), length, 1, function()
				self:StopSound( "zombie_noise" );
			end );
		end
	},
	demogorgon = {
		model = "models/players/mj_dbd_qk_playermodel.mdl",
		hands = "models/players/mj_dbd_qk_arms.mdl",
		speed = 400,
		health = function( self )
			return table.Count( player:GetAll() )*500;
		end,
		jumpPower = 450,
		getBodyGroups = function( self )
			return "0000000";
		end,
		SpecAttack = function( self )

		end
	},
};

for k,v in pairs(PLAYER.models) do
	AddPlayerModel( k, v.model, v.hands );
end

function GM:CalcView( ply, origin, angles, fov, znear, zfar )
	if (IsValid(ply) and !ply:InVehicle() and !PLAYER.firstperson) then
		return THIRDPERSON:Cam( ply, origin, angles, fov );
	end
	if (IsValid(ply) and ply:InVehicle() and !IsEmpty(ply:GetVehicle():GetParent()) and !IsEmpty(ply:GetVehicle():GetParent():GetClass()) and ply:GetVehicle():GetParent():GetClass() == "raven") then
		return THIRDPERSON:RavenCam( ply, origin, angles, fov );
	end
end
function GM:PlayerButtonDown( ply, button )
	if (CLIENT and button == 95 and PLAYER.time.firstperson < CurTime()) then
		PLAYER.firstperson = !PLAYER.firstperson;
		PLAYER.time.firstperson = CurTime()+0.3;
	end
end

function PLAYER:GetRandomSP()
    if MAP.spawnpoint and #MAP.spawnpoint > 0 then
        local randomIndex = math.random(1, #MAP.spawnpoint)
        return MAP.spawnpoint[randomIndex]
    else
        -- Возвращаем какую-то точку по умолчанию, если таблица пуста или не найдена
        return Vector(0, 0, 0)
    end
end
