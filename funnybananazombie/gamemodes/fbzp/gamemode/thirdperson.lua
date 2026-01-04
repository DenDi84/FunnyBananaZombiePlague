THIRDPERSON = {};

function THIRDPERSON:Cam( ply, pos, angles, fov )
	if ( !IsValid(ply) ) then return; end
		local view = {};
		local headpos = pos;
		if (!IsEmpty(ply:LookupBone( 'ValveBiped.Bip01_Head1' ))) then
			headpos = ply:GetBonePosition( ply:LookupBone( 'ValveBiped.Bip01_Head1' ) );
		end
		view.origin = headpos-( angles:Forward()*150);

		local tr = util.TraceLine({
			start = headpos,
			endpos = view.origin,
			filter = ply,
			maxs = Vector(5, 5, 5),
			mins = Vector(-5, -5, -5)
		});
		if (tr.Entity != NULL) then
			view.origin = headpos-( angles:Forward()*(headpos:Distance( tr.HitPos )-1));
		end

		-- view.origin = headpos+( angles:Forward()*(headpos:Distance( tr.HitPos )-1));

		view.angles = angles;
		-- view.angles = angles + Angle(0,180,0);
		view.fov = fov;
		view.drawviewer = true;
		return view;
end

function THIRDPERSON:RavenCam( ply, pos, angles, fov )
	local view = {};
	local headpos = ply:GetParent():GetPos();
	view.origin = headpos - angles:Forward()*50 - angles:Up()*-20;
	local tr = util.TraceLine({
		start = headpos,
		endpos = view.origin,
		filter = ply:GetParent(),
		maxs = Vector(5, 5, 5),
		mins = Vector(-5, -5, -5)
	});
	if (tr.Entity != NULL) then
		view.origin = headpos-( angles:Forward()*(headpos:Distance( tr.HitPos )-1));
	end
	view.angles = angles;
	view.fov = fov;
	view.drawviewer = true;
	return view;
end

function DrawName( ply )
	local my = LocalPlayer();
	if (!ply:Alive()) then return end
	if (my:GetPos():Distance( ply:GetPos() ) > 200) then return end
	if (my == ply) then return end
 
	local offset = Vector( 0, 0, 75 )
	local ang = LocalPlayer():EyeAngles();
	local pos = ply:GetPos();
	if (!IsEmpty(ply:LookupBone( 'ValveBiped.Bip01_Head1' ))) then
			pos = ply:GetBonePosition( ply:LookupBone( 'ValveBiped.Bip01_Head1' ) );
			offset = Vector( 0, 0, 15 );
	end
	pos = pos + offset + ang:Up()
 
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
 
	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )
		draw.DrawText( ply:GetName().." ( "..math.ceil(ply:Health() / (ply:GetMaxHealth() / 100)).."% )", "DermaLarge", 2, 2, ColorAlpha( team.GetColor( ply:Team() ), 255 ), TEXT_ALIGN_CENTER );
	cam.End3D2D()
 
end
hook.Add( "PostPlayerDraw", "player.DrawName", DrawName );

