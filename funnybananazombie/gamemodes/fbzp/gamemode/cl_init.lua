-- DEFINE_BASECLASS( "gamemode_base" );
include( "shared.lua" );
include( "fonts.lua" );
include( "tools.lua" );
include( "thirdperson.lua" );
include( "htmlhud.lua" );
include( "hud.lua" );
include( "nightvision.lua" );
include( "sounds.lua" );
include( "fb_swep.lua" );
include( "player.lua" );

function GM:Initialize()
	self:WelcomeText();
	timer.Create( "Welcome", 600, 0, function()
		self:WelcomeText();
	end );
end

function GM:WelcomeText()
	chat.AddText( color().red, "Наш Discord сервер → https://discord.gg/x3EKg4a");
	chat.AddText( color().blue, "Сайт проекта → http://zombieplague.ru");
	chat.AddText( color().yellow, "Магазин → ", color().blue, "Q", color().yellow, ", Смена карты → ", color().blue, "F2", color().yellow, ", Выбор оружия → ", color().blue, "С");
end
 
hook.Add("HUDPaint", "HUD.main", function()
	NIGHTVISION:Zombie();
end );
hook.Add( "PostPlayerDraw", "HUD.postplayerdraw", function()
	-- HUD:NotifyDamage();
end );

-- Сообщения в чат
function GM:ChatText( index, name, text, type )
	if ( type == "joinleave" ) then return true; end
	if ( type == "none" ) then
		--print("SUKA3: ",text)
		HUD:Message(text);
		return true;
	end
end
function GM:HUDPaint()
	
end


function screen()
	return {
		x = surface.ScreenWidth(), 
		y = surface.ScreenHeight(),
		center = {
			x = surface.ScreenWidth() / 2,
			y = surface.ScreenHeight() / 2
		}
	};
end

function GM:HUDShouldDraw(name)
	local hide = { "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo" };
	for k, element in pairs (hide) do
		if name == element then return false end
	end
	return true;
end

function GM:PostDrawOpaqueRenderables()
	
end

function DrawRottenHands( vm, ply, weapon )
	-- if CLIENT then
	-- 	hskin = LocalPlayer():GetSkin();
	-- 	local hands = LocalPlayer():GetHands();
	-- 	if ( weapon.UseHands || !weapon:IsScripted() ) then
	-- 		if ( IsValid( hands ) ) then
	-- 			hands:DrawModel();
	-- 			hands:SetSkin(hskin);
	-- 		end
	-- 	end
	-- end
end
hook.Add("PostDrawViewModel", "Set player hand skin", DrawRottenHands)