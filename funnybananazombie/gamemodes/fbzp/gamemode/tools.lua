-- Определение точки спавна
function FindPointToSpawn( pos, radius )
	local w = 40;
	local check = true;

	IsPointBusy = function(pos)
		local tr = {
			start = pos,
			endpos = pos,
			mins = Vector( -20, -20, 0 ),
			maxs = Vector( 20, 20, 75 )
		}
		local hullTrace = util.TraceHull( tr )
		if ( hullTrace.Hit ) then return true; end
		return false
	end
	for i=1,radius do
		if (i%2==0) then
			for a=1,i do
				pos.x = pos.x + w;
				if (check) then check = IsPointBusy( pos ) end
				if (!check) then return pos; end
			end
			for a=1,i do
				pos.y = pos.y + w;
				if (check) then check = IsPointBusy( pos ) end
				if (!check) then return pos; end
			end
		else
			for a=1,i do
				pos.x = pos.x - w;
				if (check) then check = IsPointBusy( pos ) end
				if (!check) then return pos; end
			end
			for a=1,i do
				pos.y = pos.y - w
				if (check) then check = IsPointBusy( pos ) end
				if (!check) then return pos; end
			end
		end
		if (!check) then break end
	end
	if (check) then return false; end
	
end

function color()
	return {
		black = Color ( 0, 0, 0 ),
		blue = Color( 62, 151, 238 ),
		red = Color( 233, 82, 69 ),
		green = Color( 148, 182, 86 ),
		salate = Color( 67, 132, 27 ),
		yellow = Color( 248, 216, 35 ),
		white = Color( 255, 255, 255),
		gray = Color( 170, 170, 170 ),
	};
end

function GetTeamColor( team )
	if ( team == 1 ) then
		return { team = color().blue, blood = color().red };
	elseif ( team == 2 ) then
		return { team = color().green, blood = color().green };
	else
		return { team = color().gray, blood = color().gray };
	end
end

function GetAlive()
	local human = 0;
	local zombie = 0;
	local spec = 0;
	for k,v in pairs( player:GetAll() ) do
		local team = v:Team();
		if ( team == 1 and v:Alive() ) then human = human + 1; end
		if ( team == 2 and v:Alive() ) then zombie = zombie + 1; end
		if ( team != 1 and team != 2 ) then spec = spec + 1; end
	end
	return { human = human, zombie = zombie, spec = spec };
end

function GetAliveList( index )
	local playertable = {};
	for k,v in pairs( team.GetPlayers( index ) ) do
		if (v:Alive()) then
			table.insert( playertable, {
				Ping = v:Ping(),
				Name = v:GetName(),
				Frags = v:Frags(),
				Deaths = v:Deaths(),
				SteamID64 = v:SteamID64() or 0,
				Avatar = v:GetNWString("avatar", "")
			} );
		end
	end
	return playertable;
end

function GetSpectateList()
	local playertable = {};
	for k,v in pairs( player:GetAll() ) do
		local myteam = v:Team();
		if ( (myteam != 1 and myteam != 2 and myteam != 3) or !v:Alive() ) then
			table.insert( playertable, {
				Ping = v:Ping(),
				Name = v:GetName(),
				Frags = v:Frags(),
				Deaths = v:Deaths(),
				SteamID64 = v:SteamID64() or 0,
				Frags = v:Frags(),
				Avatar = v:GetNWString("avatar", "")
			} );
		end
	end
	return playertable;
end

function GetWeaponIcon( name )
	local weapons = {
		weapon_pistol = { icon = "%", font = "Icontext", offset = { x = 0, y = 0 } },
		weapon_shotgun = { icon = "(", font = "Icontext", offset = { x = 0, y = 0 } },
		weapon_frag = { icon = "_", font = "Icontext", offset = { x = 0, y = 0 } },
		weapon_smg1 = { icon = "&", font = "Icontext", offset = { x = 0, y = 0 } },
		zp_mine = { icon = "z", font = "Icontext", offset = { x = 0, y = 0 } },
		zp_barricade = { icon = "\\", font = "Icontext", offset = { x = 0, y = 0 } },
		zp_infect = { icon = "~", font = "Icontext", offset = { x = 0, y = 0 } },
		weapon_357 = { icon = "$", font = "Icontext", offset = { x = 0, y = 0 } }
	};

	if (!IsEmpty(weapons[name])) then
		return weapons[name];
	end
	return false;
end

function TakeMoney(out, rec, amount)
	if ( amount < 1 ) then return; end
	if ( out:GetMoney() < amount ) then
		out:ChatPrint("error: У вас нет $"..amount..".");
		return;
	end
	if ( !IsValid( rec ) ) then
		out:ChatPrint("error: Игрок не найден.");
		return;
	end
	rec:AddMoney( amount );
	rec:ChatPrint("success: Игрок "..out:GetName().." перевёл вам $"..amount);
	out:ReduceMoney( amount );
	rec:ChatPrint("success: Вы успешно перевели $"..amount.." игроку "..rec:GetName());
end
function GetInflictorName( attacker, inflictor )
	local weaponname = "suicide";
	if ( inflictor:IsWeapon() ) then
		weaponname = inflictor:GetClass();
	else
		local activeweapon = attacker:GetActiveWeapon();
		if (activeweapon:IsWeapon()) then
			weaponname = activeweapon:GetClass();
		end
	end
	if (weaponname == "npc_grenade_frag") then
		weaponname = "weapon_frag";
	end
	return weaponname;
end

-- Определяем уровень по опыту
function GetLevel( exp )
	local level = math.ceil(math.sqrt(exp/36.6));
	return {level = level, start = math.ceil((level-1)*(level-1)*36.6), finish = math.ceil(level*level*36.6)};
end

if ( SERVER ) then
	util.AddNetworkString( 'EventsMessage' );
end
function SendNotify( data, ply )
	local ply = ply or false;
	net.Start('EventsMessage');
	net.WriteTable( data );
	if ( !ply ) then
		net.Broadcast();
	else
		net.Send( ply );
	end
end
function SendNotifyServer( data )
	net.Start( "EventsMessageServer" );
	net.WriteTable( data );
	net.SendToServer();
end

function TeamCountChange()
	local alive = GetAlive();
	SendNotify( { 
		type = "teamcounter", 
		CountHuman = alive.human,
		CountZombie = alive.zombie
	});
end

function AddPlayerModel( name, model, hands )
	player_manager.AddValidModel( name, model );
	player_manager.AddValidHands( name,	hands, 0, "00000000" );
	list.Set( "PlayerOptionsModel", name, model );
end

team.SetUp( 1, "Человек", color().blue );
team.SetUp( 2, "Зомби", color().green );
team.SetUp( 3, "Наблюдатель", color().gray );