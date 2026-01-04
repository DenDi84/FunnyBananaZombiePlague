HUD = {};
HUD.FlashText = {};
HUD.kill = {};
HUD.damage = {};
HUD.owner = NULL;



-- render.DrawTextureToScreenRect("zombieplague/trafficcone/trafficcone001a", screen().center.x, screen().center.y, 100, 100 )

HUD.translate = {
	timeout = {
		text = "Time is over...",
		sound = "",
		color = color().white
	},
	zombie_win = {
		text = "Zombies wins",
		sound = "",
		color = color().green
	},
	human_win = {
		text = "Humans wins",
		sound = "",
		color = color().blue
	},
	equality = {
		text = "No winner",
		sound = "",
		color = color().blue
	}
};

function HUD:Initialize()
	self.owner = LocalPlayer();
	if (!IsValid(self.owner)) then return; end 
	if (self.owner:KeyDown( IN_SCORE )) then return; end 
	self.weapon = self.owner:GetActiveWeapon();
	if (self.owner:Alive() and !self.owner:InVehicle() and self.owner:Health() >= 0) then 
		self:HealthHud();
	end
	if (self.weapon:IsWeapon()) then
		self:AmmoHud();
		self:DrawWeapons();
		self:NotifyDamage()
	end
	self:DrawMoney();
	self:FlashScreen();
	self:NotifyKill();
end

function HUD:Message( text )
	--print("SUKA: ",text)
	if (#text > 8 and string.sub( string.lower( text ), 1, 8 ) == "winner: ") then
		local command = string.sub( string.lower( text ), 9);
		self.FlashText = {
			text = command,
			time = CurTime(),
		};
		return;
	end
	if (#text > 8 and string.sub( string.lower( text ), 1, 7 ) == "sound: ") then
		local sound = string.sub( string.lower( text ), 8);
		surface.PlaySound( sound..".wav" );
		--print(sound)
		return;
	end
	if (#text > 6 and string.sub( string.lower( text ), 1, 7 ) == "error: ") then
		chat.AddText( color().red, string.sub( string.lower( text ), 8) );
		return;
	end
	if (#text > 10 and string.sub( string.lower( text ), 1, 9 ) == "success: ") then
		chat.AddText( color().green, string.sub( string.lower( text ), 10) );
		return;
	end
	if (text == "catalog") then
		local items = SHOP:SortByPrice();
		chat.AddText( color().red, "Товаров в магазине: "..table.Count( items ));
		for k,v in pairs( items ) do
			chat.AddText( color().blue, v.name, color().yellow, " ( $"..v.price.." ) ", color().white, " → ", color().green, "buy "..k );
		end
		return;
	end
end
