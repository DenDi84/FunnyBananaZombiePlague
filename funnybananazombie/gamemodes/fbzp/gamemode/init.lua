AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );
AddCSLuaFile( "fonts.lua" );
AddCSLuaFile( "map.lua" );
AddCSLuaFile( "models.lua" );
AddCSLuaFile( "command.lua" );
AddCSLuaFile( "chat.lua" );
AddCSLuaFile( "db.lua" );
AddCSLuaFile( "player.lua" );
AddCSLuaFile( "fb_swep.lua" );
AddCSLuaFile( "sounds.lua" );
AddCSLuaFile( "tools.lua" );
AddCSLuaFile( "hud.lua" );
AddCSLuaFile( "htmlhud.lua" );
AddCSLuaFile( "thirdperson.lua" );
AddCSLuaFile( "nightvision.lua" );
include( 'shared.lua' );
include( 'tools.lua' );
include( 'player.lua' );
include( 'map.lua' );
include('command.lua');
include('chat.lua');
include('hud.lua');

GM.addons = {
	zp_hud = { id = 3509930677, path = "gamemodes/"..GM.constants.name.."/gma/fbzphuddl.gma"  },
	zp_fonts = { id = 1989160923, path = "gamemodes/"..GM.constants.name.."/gma/zp_fonts.gma" },
	zp_hide_arena = { id = 1981575363, path = "gamemodes/"..GM.constants.name.."/gma/zp_hide_arena.gma" },
	zp_tundra = { id = 2015667217, path = "gamemodes/"..GM.constants.name.."/gma/zp_tundra.gma" },
	zp_drainage_of_the_dead = { id = 1993744097, path = "gamemodes/"..GM.constants.name.."/gma/zp_drainage_of_the_dead.gma" },
	zp_dark_place = { id = 2012731879, path = "gamemodes/"..GM.constants.name.."/gma/zp_dark_place.gma" },
	zp_hope = { id = 2046352157, path = "gamemodes/"..GM.constants.name.."/gma/zp_hope.gma" },
	zp_sounds = { id = 1984158157, path = "gamemodes/"..GM.constants.name.."/gma/zp_sounds.gma" },
	zp_game_contents = { id = 1988836860, path = "gamemodes/"..GM.constants.name.."/gma/zp_game_contents.gma" },
	zp_game_contents_human = { id = 1988673626, path = "gamemodes/"..GM.constants.name.."/gma/zp_game_contents_human.gma" },
	zp_game_contents_zombie = { id = 1988853660, path = "gamemodes/"..GM.constants.name.."/gma/zp_game_contents_zombie.gma" },
	zp_nemesida = { id = 2006579927, path = "gamemodes/"..GM.constants.name.."/gma/zp_nemesida.gma" },
	zp_human_weapons = { id = 1978679690, path = "gamemodes/"..GM.constants.name.."/gma/zp_human_weapons.gma" }
};

for k,v in pairs(GM.addons) do
	msg("AddWorkshop: [green "..v.id.."] ( "..k.." )");
	resource.AddWorkshop( v.id );
	if (v.path == NULL) then
		msg("Addon [yellow "..k.."] skipped...");
	elseif (file.Exists( v.path, "MOD" )) then
		game.MountGMA( v.path );
	else
		msg("\tid: [yellow "..v.id.."]");
		msg("\tpath: [yellow "..v.path.."]");
	end
end

-- resource.AddSingleFile("resource/fonts/aurebesh-condensed.ttf");
-- resource.AddSingleFile("resource/fonts/defused.ttf");

--[[GM.lua = {
	shared = { 'tools', 'sounds', 'fb_swep', 'player' },
	server = { 'db', 'chat', 'player', 'command', 'models', 'map' },
	client = { 'fonts', 'thirdperson', 'htmlhud', 'hud', 'nightvision' }
};--]]

function GM:Initialize()
	zombieplague = ents.Create("zombieplague");
	zombieplague:Spawn();
end
-- Падение игрока
function GM:GetFallDamage( ply, speed )
	return math.max( 0, math.ceil( 0.2418*speed - 140 ) )
end
-- Даёт возможность летать только админу:
function GM:PlayerNoClip( ply )
	return ply:IsAdmin();
end
-- Даёт возможность летать только админу:
function GM:CanPlayerSuicide( ply )
	return ply:IsAdmin();
end
-- Спавн игрока
function GM:PlayerSpawn( ply, transiton )
	ply:OnSpawn();
end
-- Обработка убийств
function GM:PlayerDeath( owner, inflictor, attacker )
	owner:OnDeath(attacker, inflictor);
end
-- Обработка Убийств при смене команды или раунда
function GM:PlayerSilentDeath( ply )
	ply:OnDeathSilent();
end

-- Пользователь отключился
function GM:PlayerDisconnected( ply )
	-- Оповестим всех что игрок покинул игру
	ply:SetUserDataToDB();
	ply:Log( 0, ply:Frags() );
	PrintMessage( HUD_PRINTTALK, "EXIT: "..ply:GetName() );
	
	for k,v in pairs(ents.FindByClass( "zp_barricade" )) do
		if ( IsEmpty(v:GetNWEntity("owner", NULL)) ) then
			v:Remove();
		end
	end
	-- Оповещаем о том что список игроков в командах изменился.
	timer.Simple( 1, function()
		TeamCountChange();
	end );
end

-- Отключает огонь по своим
function GM:PlayerShouldTakeDamage( ply, attacker )
	if ( ply:IsFlagSet( FL_ATCONTROLS ) or attacker:IsFlagSet( FL_ATCONTROLS )) then return false; end
	if (attacker:IsPlayer() and attacker:Team() == 2 and ply:Team() == 2 and attacker != ply and !IsEmpty(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "zp_knife") then
		ply:SetVelocity( attacker:GetAimVector() * 500 );
	end
	if (IsValid(attacker) and attacker:IsPlayer() and attacker.time.freeze > CurTime()) then return false; end
	if (IsValid(attacker) and attacker:IsPlayer() and ply:Team() == attacker:Team() and ply != attacker) then
		return false;
	elseif (attacker:GetClass() == "trigger_hurt") then
		return false;
	elseif (attacker == ply) then
		return true;
	end
	return true;
end

function GM:PlayerSay( sender, text, teamChat )
	return CHAT:OnMessage( sender, text, teamChat );
end

-- Отключаем возможность выйти из вороны.
-- TODO быть может имеет смысл снова его переписать использую велосити...?
function GM:CanExitVehicle( veh, ply )
	if (!IsEmpty(veh:GetParent()) and veh:GetParent():GetClass() == "raven") then return false; end
	return true;
end

function GM:Think()
	
end

timer.Remove( "zombie.regenerate" )
timer.Create( "zombie.regenerate", 1, 0, function() 
	for k,v in pairs( team.GetPlayers( 2 ) ) do
		v:AddHealth( 1, true );
	end
end )
timer.Remove( "timer.tick" );
timer.Create( "timer.tick", 1, 0, function() 
	for k, v in pairs( player.GetAll() ) do
		local freezetime = v:GetNWInt("freeze", 0);
		if ( freezetime > 0 and freezetime <= CurTime()) then
			v:SetNWInt("freeze", 0);
			v:RemoveFlags( FL_ATCONTROLS );
			v:SetColor( Color(255,255,255,255) );
			v:SetRenderMode( RENDERMODE_TRANSALPHA );
		end
		local waterlevel = v:WaterLevel();
		if (waterlevel > 0) then
			v:TakeDamage( (v:Team()*4)*waterlevel, v, v );
			v:ScreenFade( SCREENFADE.IN, ColorAlpha( color().red, 100 ), 0.3, 0 );
			if (v:IsOnFire()) then
				v:Extinguish();
			end
		end
	end
end )
--[[timer.Remove( "timer.exp" )
timer.Create( "timer.exp", 1, 0, function() 
	for k, v in pairs( player.GetAll() ) do
		local exp = v:GetNWInt("exp", 0);
		if (exp >= 0) then
			exp = exp + 100;
			v:SetNWInt("exp", exp);
		end
	end
end )--]]

function CreateFakePlayer()
	local plycount = #player.GetAll();
	local botcount = #player.GetBots();
	if (plycount <= 1 && botcount == 0) then
		player.CreateNextBot("ZombieBot");
	end
	if (plycount > 2 && botcount > 0) then
		player.GetBots()[1]:Kick();
	end
end

function ZombiePlagueReload()
	game.CleanUpMap();
	zombieplague = ents.Create("zombieplague");
	zombieplague:Spawn();
end

function GM:OnPlayerChangedTeam( ply, oldTeam, newTeam )
	
end

hook.Add("PlayerChangedTeam", "OnPlayerChangedTeam", function( ply, oldTeam, newTeam )

end);


function GM:PlayerConnect(ply)
end




-- print( player:GetAll()[1]:GetNWString("votemap", "none") );

-- print(player:GetAll()[1]:GetClassID())
-- player:GetAll()[1]:SetClassID( 0 );
-- PrintTable(baseclass.Get( "crow" ))

-- for k,v in pairs(ents.FindByName( "map_light" )) do
-- 	print(v,k);
-- 	echo ( v:GetKeyValues() );
-- 	v:SetKeyValue( "rendercolor", "0 0 0 255" );
-- end
