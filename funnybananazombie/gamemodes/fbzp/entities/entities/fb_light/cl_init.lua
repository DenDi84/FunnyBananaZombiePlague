include( "shared.lua" );

function ENT:Draw()
	self:DrawModel();
end

hook.Add("PreDrawEffects", "draw.fb_light", function()
	for k, v in pairs( ents.FindByClass( "fb_light" ) ) do
		local am_nightvision = DynamicLight( v:EntIndex() )
		if ( am_nightvision ) then
			am_nightvision.Pos = v:GetPos() + Vector(0,0,3);
			am_nightvision.r = 219;
			am_nightvision.g = 255;
			am_nightvision.b = 255;
			am_nightvision.Brightness = 1
			am_nightvision.Size = 2000
			am_nightvision.DieTime = CurTime()+.1;
			am_nightvision.Style = 1
		end
	end
end);