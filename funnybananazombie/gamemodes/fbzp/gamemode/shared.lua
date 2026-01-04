GM.Name = "Zombie Plague";
GM.Author = "FunnyBanana";
GM.Email = "admin@niesoft.ru";
GM.Website = "funnybanana.ru";

--[[GM.lua = {
	shared = { 'tools', 'sounds', 'fb_swep', 'player' },
	server = { 'db', 'chat', 'player', 'command', 'models', 'map' },
	client = { 'fonts', 'thirdperson', 'htmlhud', 'hud', 'nightvision' }
};--]]
GM.constants = {
	name = "funnybananazombie"
};


-- Магазин:
SHOP = {};
SHOP.discount = 0;
SHOP.items = {
	lasermine = { 
		price = 60, 
		name = "Лазерная растяжка", 
		info = "Устанавливается на стену и поражает противника который пересекает луч мины.",
		sound = true,
		limit = 5,
		access = {true, true, false}, 
		weapon = { name = "zp_mine", ammo = "mine", amount = 1 },
		init = function( self, ply ) 
			if (zombieplague.round.type != "ready") then
				ply:ChatPrint("error: Покупать мины можно до начала раунда!");
				return false;
			end
			local countmine = ply:GetAmmoCount( "mine" );
			if ( countmine < self.limit ) then
				for k,v in pairs(ents.FindByClass( "lasermine" )) do
					if ( v:GetNWEntity( "owner", NULL ) == ply ) then countmine = countmine + 1; end
				end
			end
			if ( countmine >= self.limit ) then
				ply:ChatPrint("error: Нельзя иметь больше "..self.limit.."-ти мин.");
				return false;
			end
			ply:SetNWInt( "lasermine", ply:GetNWInt( "lasermine", 0 ) + 1 );
			return true; 
		end 
	},
	barricade = {
		price = 40, 
		name = "Баррикада", 
		info = "Небольшое заграждение позволяет забаррикадировать проход конусом.",
		sound = true,
		limit = 5,
		access = {true, true, false},
		weapon = { name = "zp_barricade", ammo = "ammo_barricade", amount = 1 },
		init = function( self, ply ) 
			if (zombieplague.round.type != "ready") then
				ply:ChatPrint("error: Покупать баррикады можно до начала раунда!");
				return false;
			end
			local countbarricade = ply:GetAmmoCount( "ammo_barricade" );
			if ( countbarricade < self.limit ) then
				for k,v in pairs(ents.FindByClass( "barricade" )) do
					if ( v:GetNWEntity( "owner", NULL ) == ply ) then countbarricade = countbarricade + 1; end
				end
			end
			if ( countbarricade >= self.limit ) then
				ply:ChatPrint("error: Нельзя иметь больше "..self.limit.."-ти баррикад.");
				return false;
			end
			ply:SetNWInt( "barricade", ply:GetNWInt( "barricade", 0 ) + 1 );
			return true; 
		end 
	},
	medkit = {
		price = 70, 
		name = "Аптечка", 
		info = "Аптечка которая может восстанавливать твоё здоровье и здоровье твоих напарников.",
		sound = true,
		access = {true, false, false},
		weapon = { name = "weapon_medkit", ammo = false, amount = 1 },
		init = function( self, ply ) return true; end 
	},
	infection = {
		price = 300, 
		name = "Инфекционная граната", 
		info = "Граната содержащая вирус, заражает людей со слабым иммунитетом или наносит урон.",
		sound = true,
		access = {false, true, false},
		weapon = { name = "zp_infect", ammo = "infect_grenade", amount = 1 },
		init = function( self, ply )
			if (zombieplague.round.type == "hero" or zombieplague.round.type == "demogorg") then
				ply:ChatPrint("error: В этом режиме инфекционные гранаты недоступны!");
				return false;
			end
			return true; 
		end 
	},
	ammo = {
		price = 40, 
		name = "Дополнительные патроны", 
		info = "Дополнительный комплект боезапаса.",
		sound = true,
		access = {true, false, false},
		weapon = { name = false, ammo = false, amount = 0 },
		init = function( self, ply ) 
			ply:GiveAmmo( 100, "pistol", true );
			ply:GiveAmmo( 300, "ar2", true );
			ply:GiveAmmo( 300, "Buckshot", true );
			ply:GiveAmmo( 300, "SMG1", true );
			ply:GiveAmmo( 300, "357", true );
			return true;
		end 
	},
	health = {
		price = 50, 
		name = "Дополнительное здоровье", 
		info = "Так же увеличивает максимальный запас здоровья.",
		sound = false,
		access = {true, true, false},
		weapon = { name = false, ammo = false, amount = 1 },
		init = function( self, ply ) 
			if (zombieplague.round.type == "hero" or zombieplague.round.type == "demogorg") then
				ply:ChatPrint("error: Покупка здоровья в этом режиме недоступна!");
				return false;
			end
			local myteam = ply:Team();
			local newhealth = ply:Health() + 50 * myteam;
			local maxhealth = ply:GetMaxHealth();
			if ( newhealth > 1500 * myteam) then
				ply:ChatPrint("error: Больше здоровья взять нельзя!");
				return false;
			end
			ply:SetHealth( newhealth );
			if ( maxhealth < newhealth ) then
				ply:SetMaxHealth( newhealth );
			end
			ply.WhirrSound = CreateSound(ply, "items/medshot4.wav");
			ply.WhirrSound:PlayEx( 0.5, 255 );
			return true;
		end 
	},
	revolver = {
		price = 90, 
		name = "Револьвер", 
		info = "Добавляет револьвер к твоему боекомплекту.",
		sound = true,
		access = {true, false, false},
		weapon = { name = "weapon_357", ammo = "357", amount = 12 },
		init = function( self, ply ) return true; end 
	},
	jump = {
		price = 30, 
		name = "Увеличить силу прыжка", 
		info = "Увеличивает высоту прыжка",
		sound = true,
		access = {true, true, false},
		weapon = { name = false, ammo = false, amount = 1 },
		init = function( self, ply ) 
			if ( ply:GetJumpPower() < 350 ) then
				ply:SetJumpPower( 350 );
				return true; 
			end
			ply:ChatPrint("error: Сильнее прыгать уже нельзя.");
			return false;
		end 
	},
	run = {
		price = 40, 
		name = "Увеличить скорость бега", 
		info = "Увеличивает скорость",
		sound = true,
		access = {true, true, false},
		weapon = { name = false, ammo = false, amount = 1 },
		init = function( self, ply ) 
			if ( ply:GetMaxSpeed() < 500 ) then
				local nowspeed = ply:GetMaxSpeed();
				ply:SetMaxSpeed( nowspeed + 100 );
				ply:SetRunSpeed( nowspeed + 100 );
				ply:SetWalkSpeed( nowspeed + 100 );
				return true; 
			end
			ply:ChatPrint("error: Быстрее бегать нельзя.");
			return false;
		end 
	},
	antidote = {
		price = 200, 
		name = "Антидот", 
		info = "Сыворотка излечивающая мутацию.",
		sound = true,
		access = {false, true, false},
		weapon = { name = false, ammo = false, amount = 1 },
		init = function( self, ply ) 
			if (zombieplague.round.type == "hero" or zombieplague.round.type == "demogorg" or zombieplague.round.type == "battle") then
				ply:ChatPrint("error: В этом режиме антидот недоступен!");
				return false;
			end
			if ( GetAlive().zombie > 1 ) then
				ply:SetHuman()
				return true; 
			end
			ply:ChatPrint("error: Ты единственный зомби.");
			return false;
		end 
	},
};




function SHOP:SortByPrice()
	local mytable = self.items;
	table.SortByMember(mytable, "price");
	return mytable;
end

function SHOP:CheckAccess( access, ply )
	if ( !access[ply:Team()] ) then
		ply:ChatPrint("error: Этот товар не для тебя.");
		return false;
	end
	return true;
end
function SHOP:CheckMoney( price, ply )
	local money = ply:GetMoney();
	if ( money < price ) then
		ply:ChatPrint("error: Не хватает: $"..math.ceil(price - money));
		return false;
	end
	return true;
end
function SHOP:Buy(price, ply)
	--[[if (ply:IsAdmin()) then
		ply:ChatPrint("success: С администраторов деньги не берём ;-)");
		return true;
	end--]]

	local level = GetLevel( ply:GetNWInt("exp", 0) );
	local skidka = price / 100 * (self.discount + level.level);
	if (skidka > 0) then
		ply:ChatPrint("success: Вы получили скидку  → $"..math.ceil(skidka));
	end
	ply:ReduceMoney( price - skidka );
end


function IsEmpty(s)
	return s == nil or s == '' or s == NULL;
end

-- расскрашиваем вывод в консоль:
function msg( text )
	text = string.Replace( text, "[red ", "\x1b[31;1m" );
	text = string.Replace( text, "[green ", "\x1b[32;1m" );
	text = string.Replace( text, "[yellow ", "\x1b[33;1m" );
	text = string.Replace( text, "[blue ", "\x1b[34;1m" );
	text = string.Replace( text, "[cyan ", "\x1b[36;1m" );
	text = string.Replace( text, "]", "\x1b[0m" );
	print( text );
end

-- Преобразуем секунды в минуты
function GetMinuteFromSec( sec )
	if (sec == nil) then sec = 0; end
	local minutes = math.floor(sec / 60);
	local seconds = sec - (minutes * 60);
	if (minutes < 10) then minutes = "0"..minutes; end
	if (seconds < 10) then seconds = "0"..seconds; end
	return { time = minutes..":"..seconds, source = sec };
end

-- Выводит в консоль текст или таблицу:
function echo( val )
	if ( istable( val ) and !IsEmpty( val ) ) then
		PrintTable( val );
	else
		print( val );
	end
end


