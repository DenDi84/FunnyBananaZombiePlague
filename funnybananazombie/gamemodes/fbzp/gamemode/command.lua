local admincommand = {
	teleportin = function( ply, target )
		target:SetPos( FindPointToSpawn( ply:GetPos(), 10 ) );
		return true;
	end,
	teleportout = function( ply, target )
		ply:SetPos( FindPointToSpawn( target:GetPos(), 10 ) );
		return true;
	end,
	playerzombie = function( ply, target )
		target:SetZombie();
		return true;
	end,
	playerhuman = function( ply, target )
		target:SetHuman();
		return true;
	end,
	playerkill = function( ply, target )
		target:Kill();
		return true;
	end,
	playerkick = function( ply, target )
		target:Kick( "Администратор "..ply:GetName().." отправил вас отдохнуть." );
		return true;
	end,
	playerdemogorg = function( ply, target )
		zombieplague:SetDemogorg( target );
		print( "Администратор "..ply:GetName().." сделал демогоргом игрока "..target:GetName() );
		return true;
	end,
	playerhero = function( ply, target )
		zombieplague:SetHero( target );
		print( "Администратор "..ply:GetName().." сделал героем игрока "..target:GetName() );
		return true;
	end,
	playerinfection = function( ply, target )
		zombieplague:SetFirstZombie( target );
		print( "Администратор "..ply:GetName().." сделал первым зомби игрока "..target:GetName() );
		return true;
	end
};
-- Магазин:
concommand.Add( "buy", function( ply, cmd, args )
	if (IsEmpty(args[1])) then
		ply:ChatPrint("catalog");
		return;
	end
	local items = SHOP.items[args[1]];
	if (!IsEmpty(items) and ply:Alive()) then
		local team = ply:Team();
		if ( !SHOP:CheckAccess( items.access, ply ) ) then return false; end
		if ( !SHOP:CheckMoney( items.price, ply ) ) then return false; end
		if ( items.weapon.name and !ply:HasWeapon( items.weapon.name ) ) then 
			ply:Give( items.weapon.name ); 
		end
		if (items:init( ply ) ) then
			if (items.sound) then
				ply.WhirrSound = CreateSound(ply, "ambient/machines/keyboard1_clicks.wav");
				ply.WhirrSound:PlayEx( 0.8, 255 );
			end
			if ( items.weapon.ammo and items.weapon.amount > 0 and ply:HasWeapon( items.weapon.name ) ) then 
				ply:GiveAmmo( items.weapon.amount, items.weapon.ammo, true );
			end
			SHOP:Buy(items.price, ply);
		end
	else
		ply:ChatPrint("catalog");
	end
end );
concommand.Add( "take_money", function( ply, cmd, args )
	local target = player.GetBySteamID64( args[2] );
	if (IsValid(target) and target:IsPlayer()) then
		TakeMoney(ply, target, tonumber(args[1]));
	end
end );

-- Установка оружия по умолчанию
concommand.Add( "select_def_weapon", function( ply, cmd, args )
	ply:SetWeaponDefault(args[1], args[2]);
end );



-- Голосование за смену карты
concommand.Add( "votemap", function( ply, cmd, args )
	if ( !IsEmpty( args[1] ) ) then
		ply:SetNWString("votemap", args[1]);
	end
end );

-- Голосование за смену карты
concommand.Add( "spec", function( ply, cmd, args )
	ply:SetNWBool("spec", !ply:GetNWBool("spec", false));
	ply:KillSilent();
end );


-- Функции администратора
concommand.Add( "event", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	ZombiePlagueReload();
end );
concommand.Add( "night", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	zombieplague:ToggleLight();
end );
concommand.Add( "human", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	ply:SetHuman();
end );
concommand.Add( "zombie", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	ply:SetZombie();
end );
concommand.Add( "raven", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	ply:SetRaven();
end );
concommand.Add( "nemesida", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	ply:SetNemesida();
end );
concommand.Add( "battle", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	zombieplague.change.battle = true;
end );
concommand.Add( "hero", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	ply:SetHero();
end );
concommand.Add( "nextmap", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	MAP:Change( args[1] );
end );
concommand.Add( "admin", function( ply, cmd, args )
	if (!ply:IsAdmin() or IsEmpty(args[1]) or IsEmpty(args[2])) then return end
	local target = player.GetBySteamID64( args[2] ) or player.GetBots()[1];
	if (!IsEmpty(admincommand[args[1]]) and IsValid(target)) then
		admincommand[args[1]]( ply, target );
	end
end );

concommand.Add( "swep", function( ply, cmd, args )
	if (!ply:IsAdmin() or IsEmpty(args[1]) or IsEmpty(args[2])) then return end
	local target = player.GetBySteamID64( args[1] );
	if ( target and target:IsPlayer() ) then
		target:Give(args[2]);
	end
end );

concommand.Add( "swepall", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	if (IsEmpty(args[1])) then
		for k,v in pairs(player:GetAll()) do
			for kk,vv in pairs(SERVERWEAPONS) do v:Give(kk); end
		end
	else
		for k,v in pairs(player:GetAll()) do
			v:Give(args[1]);
		end
	end
end );




concommand.Add( "bot_add", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	for i=1,args[1] or 1 do
		player.CreateNextBot( "Bot "..#player.GetBots() );
	end
end );
concommand.Add( "bot_kick", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	for k,v in pairs(player.GetBots()) do
		v:Kick();
	end
end );
concommand.Add( "check", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	echo (ply:GetEyeTrace().Entity);
end );

concommand.Add( "test", function( ply, cmd, args )
	if (!ply:IsAdmin()) then return end
	ply:EmitSound("aheli_rotor");
	timer.Create("StopSpecAttackSound", 10, 1, function()
		ply:StopSound( "aheli_rotor" );
	end );
end );


