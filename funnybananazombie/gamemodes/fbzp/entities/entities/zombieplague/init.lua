AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );


function ENT:Initialize()
	self:SetModel("models/props_lab/workspace001.mdl");
	self:SetNoDraw( true );
	self:SetName("events");
	self:Start();
	self:SetPos( MAP.spawnpoint[1] );
end

function ENT:Think()
	roundType = self.round.time;
	local finish = self:CheckFinish();
	if (finish.status) then
		self:Next( finish.winner ); 
	else
		self.round.time = self.round.time - 1;
		self.round.length = self.round.length + 1;
		if ( self.round.time < 0 ) then self.round.time = 0; end
	end

	self:Send();
	self:NextThink( CurTime() + 1 );
	return true;
end



function ENT:Send()
	self:SetNWString("round.type", self.round.type );
	self:SetNWString("round.name", self.round.name );
	self:SetNWInt("round.time", self.round.time );
	self:SetNWInt("round.length", self.round.length );
end

function ENT:CheckFinish()
	local alive = GetAlive();
	if ( #player.GetAll() < 2 ) then
		return { status = false };
	elseif ( self.round.time == 0 and self.round.type == "escape") then 
		if (alive.zombie > 0) then return { status = true, winner = "zombie_win" }; end
		if (alive.zombie == 0 and alive.human == 0) then return { status = true, winner = "equality" }; end
		return { status = true, winner = "human_win" };
	elseif ( self.round.time == 0 ) then 
		return { status = true, winner = "timeout" }; 
	elseif ( self.round.type != "ready" and alive.human == 0 and alive.zombie > 0 ) then 
		return { status = true, winner = "zombie_win" };
	elseif ( self.round.type != "ready" and alive.zombie == 0 and alive.human > 0 ) then
		return { status = true, winner = "human_win" };
	elseif ( self.round.type != "ready" and alive.human == 0 and alive.zombie == 0 ) then
		return { status = true, winner = "equality" };
	end
	return { status = false };
end

function ENT:Start()
	local allp = player:GetAll()
	for k,v in pairs(allp) do
		v:KillSilent();
		v:Spawn();
		v:ScreenFade( SCREENFADE.IN, ColorAlpha( color().black, 200 ), 0.3, 0.3 );
	end
	--print('ENT:START STARTED"')
	local checkvotemap = self:CheckVotemap();
	if ( checkvotemap.change == true ) then
		local nextmap = checkvotemap.name
		BroadcastLua(string.format(
        "chat.AddText(Color(100,100,255), 'Next map in 10 seconds is going to be... ', Color(255,69,0), '%s')",
        nextmap
    ))
		timer.Create("nextmapisgoing", 10, 1,function ()
			MAP:Change( nextmap );
		end)
	end
end

function ENT:Next( winner )
	if ( self.round.type == "ready" ) then
		local nextevent = table.Random( self.list );
		if ( nextevent.type == "demogorg" ) then nextevent = table.Random( self.list ); end
		if ( nextevent.type == "hero" ) then nextevent = table.Random( self.list ); end
		if ( nextevent.type == "battle" ) then 
			nextevent = table.Random( self.list ); 
			if ( nextevent.type == "battle" ) then nextevent = table.Random( self.list ); end
		end
		if (self.change.battle == true) then
			nextevent = self.list[7];
		end
		local humancount = GetAlive().human;
		local humans = team.GetPlayers( 1 );
		self.round = nextevent;
		if ( humancount > 1 ) then
			if ( !IsEmpty(self.change.hero) and IsValid(self.change.hero) and self.change.hero:IsPlayer() ) then
				self.round = self.list[6];
				self.change.hero:SetHero();
				for k,v in pairs(team.GetPlayers( 1 )) do
					if (self.change.hero != v) then v:SetZombie(); end
				end
			elseif ( !IsEmpty(self.change.demogorg) and IsValid(self.change.demogorg) and self.change.demogorg:IsPlayer() ) then
				self.round = self.list[5];
				self.change.demogorg:SetNemesida();
			elseif ( !IsEmpty(self.change.infection) and IsValid(self.change.infection) and self.change.infection:IsPlayer() ) then
				self.round = self.list[1];
				self.change.infection:SetZombie();
				self.change.infection:SetMaxHealth( 2000 );
				self.change.infection:SetHealth( 2000 );
				self:ToggleLight();
			elseif ( self.round.type == "escape" ) then
				local firstzombie = table.Random( humans );
				firstzombie:SetZombie();
				firstzombie:SetMaxHealth( firstzombie:GetMaxHealth() * 2 );
				firstzombie:SetHealth( firstzombie:GetMaxHealth() );
				timer.Create( "zombieplagueroundTimer", 180, 1, function()
					self:CreateEscape();
				end );
			elseif ( self.round.type == "infection" ) then
				local firstzombie = table.Random( humans );
				firstzombie:SetZombie();
				firstzombie:SetMaxHealth( 2000 );
				firstzombie:SetHealth( 2000 );
				self:ToggleLight();
			elseif( self.round.type == "survival" ) then
				for i=1,math.ceil( humancount / 2 ) do
					table.Random( team.GetPlayers( 1 ) ):SetZombie();
				end
			elseif( self.round.type == "invasion" ) then
				for i=1,math.ceil( humancount / 3 ) do
					table.Random( team.GetPlayers( 1 ) ):SetZombie();
				end
				self:ToggleLight();
			elseif( self.round.type == "massinfection" ) then
				for i=1,math.ceil( humancount / 3 ) do
					table.Random( team.GetPlayers( 1 ) ):SetZombie();
				end
			elseif( self.round.type == "hero" ) then
				local nowhero = table.Random( team.GetPlayers( 1 ) );
				nowhero:SetHero();
				for k,v in pairs(team.GetPlayers( 1 )) do
					if (v != nowhero) then v:SetZombie(); end
				end
			elseif( self.round.type == "battle" ) then
				for i=1,math.ceil( humancount / 2 ) do
					table.Random( team.GetPlayers( 1 ) ):SetNemesida();
				end
				for k,v in pairs(team.GetPlayers( 1 )) do
					v:SetHero();
				end
				for k,v in pairs(team.GetPlayers( 2 )) do
						v:SetMaxSpeed( 600 );
						v:SetRunSpeed( 600 );
						v:SetWalkSpeed( 600 );
				end
			elseif( self.round.type == "demogorg" ) then
				table.Random( team.GetPlayers( 1 ) ):SetNemesida();
			end
			PrintMessage( HUD_PRINTTALK, "SOUND: "..self.round.sound );
		end
	else
		PrintMessage( HUD_PRINTTALK, "SOUND: "..self.sounds[winner] );
		SendNotify( { type = "finish", text = self.roundparam[winner].finish } );
		if (self.round.type == "invasion") then
			local alive_count = GetAlive().human;
			for k,v in pairs(team.GetPlayers( 1 )) do
				if (v:Alive()) then
					if (alive_count == 1) then
						v:AddMoney( 100 );
					else
						v:AddMoney( 20 );
					end
				end
			end
		end
		self:Remove();
		timer.Simple( self.setup.spawndelay, function()
			ZombiePlagueReload();
		end)
	end
end

function ENT:CheckVotemap()
	local votemap = {};
	local allply = player:GetAll();
	for k,v in pairs(allply) do
		local playerchoose = v:GetNWString("votemap", "");
		if ( !IsEmpty( playerchoose ) ) then
			if ( IsEmpty(votemap[playerchoose]) ) then
				votemap[playerchoose] = 1;
			else
				votemap[playerchoose] = votemap[playerchoose] + 1;
			end
		end
	end
	local selectedmap = { name = nil, count = 0, change = false }
	for k,v in pairs(votemap) do
		if (v > selectedmap.count) then
			selectedmap.name, selectedmap.count = k, v;
		end
	end
	if ( selectedmap.count > 0 and selectedmap.count >= math.ceil(#allply / 2) ) then
		selectedmap.change = true;
	end
	return selectedmap;
end

function ENT:ToggleLight()
	local bt = ents.FindByName( "light_button" );
	if (!IsEmpty(bt[1])) then
		bt[1]:Use( zombieplague, zombieplague, 3, CurTime() );
	end
end

function ENT:CreateEscape()
	if self.round.type != "escape" then return end
	local escape = ents.Create("zp_escape");
	escape.point = MAP:GetEscapeTrace();
	if (!escape.point) then return false; end
	escape:SetPos( escape.point[1].pos );
	escape:SetAngles( escape.point[1].ang - Angle(0,90,0) );
	escape:Spawn();
	escape:EmitSound("aheli_rotor");
	return true;
end

function ENT:SetDemogorg( target )
	self.change.demogorg = target;
end
function ENT:SetFirstZombie( target )
	self.change.infection = target;
end
function ENT:SetHero( target )
	self.change.hero = target;
end


hook.Add( "EntityTakeDamage", "events.ondamage", function( target, dmginfo )
	local round_type = zombieplague:GetNWString("round.type", "ready");
	local attacker = dmginfo:GetAttacker();
	if (!IsValid(attacker) or round_type == "ready") then return false; end
	if (!IsValid(target) and target:IsPlayer() and !target:Alive()) then return false; end
	local damage = dmginfo:GetDamage();
	local weapon = dmginfo:GetInflictor():GetClass();
	if ( attacker:IsPlayer() and target:IsPlayer() and attacker:Team() == 1 and target:Team() != attacker:Team() and weapon != "zp_knife" and weapon != "zp_mine" ) then
		-- Отброс
		target:SetVelocity( attacker:GetAimVector() * ( damage * 0 ) + VectorRand()*50 );
	end
	if (attacker:IsPlayer() and target:IsPlayer() and weapon == "zp_knife" and attacker:Team() == 2 and target:Team() == 2) then
		target:SetVelocity( attacker:GetAimVector() * 200 );
	end
	if ( target:IsPlayer() and attacker:IsPlayer() and target:Team() != attacker:Team() ) then
		attacker:AddMoney( damage / 20 );
		if ((round_type == "infection" or round_type == "massinfection") and target:Team() == 1 and attacker:Team() == 2 and GetAlive().human > 1 and dmginfo:GetDamage() >= target:Health()) then
			target:Infect( attacker, dmginfo:GetInflictor() );
			attacker:AddHealth( 100, true );
			attacker:AddMoney( 50 );
			return false;
		end
		SendNotify( {
			type = "damage",
			target = target,
			damage = math.ceil( damage ),
			time = CurTime()
		}, attacker );
	end
	if ( target:IsPlayer() and target:Alive() and target:Team() == 3 ) then
		target:Kill();
	end
end );
hook.Add( "ScalePlayerDamage", "events.scaledamage", function( ply, hitgroup, dmginfo )
	local weapon = dmginfo:GetInflictor():GetClass();
	if( weapon == "zp_knife" and ply:Team() == 1 ) then
		dmginfo:ScaleDamage( 0.60 );
	else
		if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage( .8 ); end
		if hitgroup == HITGROUP_CHEST then dmginfo:ScaleDamage( .7 ); end
		if hitgroup == HITGROUP_STOMACH then dmginfo:ScaleDamage( .6 ); end
	end
end );

hook.Add( "DoPlayerDeath", "events.ondeath", function( target, attacker, dmginfo )
	if (!target:IsPlayer() or !attacker:IsPlayer()) then return; end
	local attacker_team = attacker:Team();
	local target_team = target:Team();
	print(attacker:GetName().."( "..attacker:SteamID().." )".." убил "..target:GetName().." ( "..target:SteamID().." )");
	if ( target == attacker ) then
		attacker:ReduceMoney( 50 );
		return;
	else
		-- Если убили ворона, то прибавленный фраг отнимаем обратно.
		if ( target:Team() == 3 ) then 
			attacker:SetFrags( attacker:Frags() - 1 ); 
			return;
		end
		-- Добавляем жизней зомби
		if ( attacker:Team() == 2) then 
			attacker:AddHealth( 100, true );
			attacker:AddMoney( 50 );
		end
		-- Добавляем запись в БД об убийстве:
		--[[if ( !target:IsBot() ) then
			target:LogKill(attacker:SteamID64(), target:SteamID64(), target_team);
		end--]]
		-- Отсылаем сообщение клиенту о том что кто-то кого-то убил.
		SendNotify( {
			type = "kill",
			target = target:GetName(),
			attacker = attacker:GetName(),
			inflictor = GetInflictorName( attacker, dmginfo:GetInflictor() ),
			time = CurTime(),
			team = {
				attacker = attacker_team,
				target = target_team
			}
		} );
	end
end );