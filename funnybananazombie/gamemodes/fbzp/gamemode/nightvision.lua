NIGHTVISION = {};

NIGHTVISION.owner = LocalPlayer();

function NIGHTVISION:Zombie()
	self.owner = LocalPlayer();
	if ( !IsValid( self.owner ) ) then return; end
	local active_weapon = self.owner:GetActiveWeapon();
	if ( !IsEmpty(active_weapon) and active_weapon:GetClass() == "zp_nemesida" ) then return; end
	if (self.owner:Team() == 2) then 
		am_nightvision = DynamicLight( self.owner:EntIndex() )
		if ( am_nightvision ) then
			am_nightvision.Pos = self.owner:EyePos();
			am_nightvision.r = 0
			am_nightvision.g = 132
			am_nightvision.b = 27
			am_nightvision.Brightness = 1
			am_nightvision.Size = 2000
			am_nightvision.DieTime = CurTime()+100000
			am_nightvision.Style = 1
		end
	else
		am_nightvision = DynamicLight( self.owner:EntIndex(), false );
	end
	-- am_nightvision.Pos = ply:GetEyeTrace().HitPos;
end