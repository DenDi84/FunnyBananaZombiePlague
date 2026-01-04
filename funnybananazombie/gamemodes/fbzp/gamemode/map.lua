MAP = {};

MAP.spawnpoint = {};

function MAP:Initialize()
	self:GetSpawnPoint();
end

--[[local hopeSP = {
	{-231,-824,384}
	{1667,-135,384}
	{1548,-1707,390}
	{1835,-1377,384}
	{1372,-1293,384}
	{1125,-815,384}
	{1100,-93,384}
	{40,226,384}
	{626,311,384}
	{-485,-164,384}
	{-872,-423,384}
	{-401,-1291,384}
	{-704,-840,384}
}

local tundraSP = {
	{-231,-824,384}
	{-231,-824,384}
	{-231,-824,384}
	{-231,-824,384}
	{-231,-824,384}
	{-231,-824,384}
	{-231,-824,384}
	{-231,-824,384}
	{-231,-824,384}
	{-231,-824,384}
	{-231,-824,384}
	{-231,-824,384}
}--]]

zp_hide_arenaSP = {
    Vector(510, 238, 66),
    Vector(1518, 220, 124),
    Vector(1328, 1243, 184),
    Vector(311, 1287, 184),
    Vector(199, 1841, 184),
    Vector(1302, 1689, 184),
    Vector(2027, 471, 64),
    Vector(1983, -453, 64),
    Vector(347, -1174, 66),
    Vector(1020, -1275, 66),
    Vector(1496, -1625, 66),
    Vector(566, -1937, 66),
    Vector(-17, -530, 64),
    Vector(-303, 763, 64)
}

zp_tundraSP = {
    Vector(-815, -994, 128),
    Vector(-134, 176, 128),
    Vector(-1056, 1020, 128),
    Vector(438, 609, 296),
    Vector(716, 741, 129),
    Vector(1090, 762, 128),
    Vector(1499, 32, 128),
    Vector(1486, -333, 258),
    Vector(2011, -277, 128),
    Vector(806, -109, 128)
}

zp_drainage_of_the_deadSP = {
    Vector(248, 1447, 112),
    Vector(-572, 1419, 112),
    Vector(-620, 2393, 112),
    Vector(-539, 3347, 112),
    Vector(204, 3311, 112),
    Vector(584, 2906, 112),
    Vector(571, 1842, 112),
    Vector(511, 719, 66),
    Vector(-6, 1041, 64),
    Vector(6, 219, 104)
}

zp_dark_placeSP = {
    Vector(552, -1244, 68),
    Vector(476, -1894, 64),
    Vector(821, -2130, 64),
    Vector(1477, -1272, 68),
    Vector(1187, -770, 64),
    Vector(1300, -419, 64),
    Vector(1872, -259, 68),
    Vector(2414, -926, 64),
    Vector(2424, -1442, 68),
    Vector(2304, -2191, 64),
    Vector(1808, -2272, 66),
    Vector(1287, -2344, 66),
    Vector(244, 85, 64),
    Vector(1610, -1667, 68)
}

zp_hopeSP = {
    Vector(-704, -840, 384),
    Vector(-401, -1291, 384),
    Vector(-836, -849, 384),
    Vector(-872, -423, 384),
    Vector(-485, -164, 384),
    Vector(40, 226, 384),
    Vector(626, 311, 384),
    Vector(1100, -93, 384),
    Vector(1125, -815, 384),
    Vector(1372, -1293, 384),
    Vector(1835, -1377, 384),
    Vector(1548, -1707, 390),
    Vector(1667, -135, 384),
    Vector(-231, -824, 384)
}

function MAP:GetSpawnPoint()
	local curmap = game.GetMap()
	if curmap == "zp_hope" then
		for k,v in ipairs(zp_hopeSP) do
			table.insert(MAP.spawnpoint, k, v)
		end
	elseif curmap == "zp_tundra" then
		for k,v in pairs(zp_tundraSP) do
			table.insert(MAP.spawnpoint, k, v)
		end
	elseif curmap == "zp_hide_arena" then
		for k,v in pairs(zp_hide_arenaSP) do
			table.insert(MAP.spawnpoint, k, v)
		end
	elseif curmap == "zp_drainage_of_the_dead" then
		for k,v in pairs(zp_drainage_of_the_deadSP) do
			table.insert(MAP.spawnpoint, k, v)
		end
	elseif curmap == "zp_dark_place" then
		for k,v in pairs(zp_dark_placeSP) do
			table.insert(MAP.spawnpoint, k, v)
		end
	end
end

function MAP:MapList()
	return {
		zp_drainage_of_the_dead = {
			name = "Drainage of the dead"
		},
		zp_hide_arena = {
			name = "Hide Arena"
		},
		zp_hope = {
			name = "Hope"
		},
		zp_dark_place = {
			name = "Dark Place"
		},
		zp_tundra = {
			name = "Tundra"
		}
	};
end

function MAP:SpawnPoints( random )
	if ( random ) then
		local points = table.Random( MAP.spawnpoint );
		--print(points)
		local spawnpoints = FindPointToSpawn( points, 4 );
		if ( !spawnpoints ) then
			return spawnpoint ;
		else
			return points;
		end
	else
		return MAP.spawnpoint;
	end
end

function MAP:Change( mapname )
	local mapname = mapname or "";
	for k,v in pairs(player:GetAll()) do

	end
	if ( IsEmpty(mapname) ) then
		game.LoadNextMap();
	else
		game.ConsoleCommand( "changelevel "..mapname.."\n" );
	end  
end

function MAP:GetEscapeTrace()
	local trace = {
		zp_dark_place = {
			{
				pos = Vector(2939, 633, 946), 
				ang = Angle(24, -140, 0), 
				fun = function( self ) 
					self:GetPhysicsObject():EnableCollisions( false );
					return 0;
				end
			},
			{
				pos = Vector(1803.3013916016, -833.12475585938, 553.11297607422),
				ang = Angle(0, -128.34126281738, 0),
				fun = function( self ) 
					self:GetPhysicsObject():EnableCollisions( true );
					return 0;
				end
			},
			{
				pos = Vector(950, -863.02984619141, 520),
				ang = Angle(0, -178.97128295898, 0),
				fun = function( self ) -- Ожидание
					self:WaitPassenger( true );
					return 30;
				end
			},
			{
				pos = Vector(654.81677246094, -936.40496826172, 613.72265625),
				ang = Angle(0, -169.74778747559, 0),
				fun = function( self )
					self:WaitPassenger( false );
					self:GetPhysicsObject():EnableCollisions(false);
					return 0;
				end
			},
			{
				pos = Vector(315.05545043945, -2012.1119384766, 677.54156494141),
				ang = Angle(0, -102.04457855225, 0),
				fun = function( self ) 
					self:Explode();
					return 0;
				end
			},
			{
				pos = Vector(-65.391799926758, -3025.9094238281, 1114.3427734375),
				ang = Angle(0, -110.67908477783, 0),
				fun = function( self ) 
					return 0;
				end
			}
		},
		zp_drainage_of_the_dead = {
			{
				pos = Vector(-1009.5594482422, -589.32733154297, 1622.1828613281),
				ang = Angle(0, 88.994941711426, 0),
				fun = function( self )
					self:GetPhysicsObject():EnableCollisions( false );
					return 0;
				end
			},
			{
				pos = Vector(-189.81845092773, 1100.4416503906, 900),
				ang = Angle(0, 57.890758514404, 0),
				fun = function( self )
					return 0;
				end
			},
			{
				pos = Vector(283.18139648438, 1965.9073486328, 725.60076904297),
				ang = Angle(0, 62.796810150146, 0),
				fun = function( self )
					self:GetPhysicsObject():EnableCollisions( true );
					return 0;
				end
			},
			{
				pos = Vector(348.30902099609, 2396.0280761719, 658.00018310547),
				ang = Angle(0, 89.681777954102, 0),
				fun = function( self )
					return 0;
				end
			},
			{
				pos = Vector(379.01715087891, 2749.8642578125, 595.66033935547),
				ang = Angle(0, 135.60188293457, 0),
				fun = function( self )
					return 0;
				end
			},
			{
				pos = Vector(-230, 2885.1071777344, 520),
				ang = Angle(0, -179.458984375, 0),
				fun = function( self )
					self:WaitPassenger( true );
					return 30;
				end
			},
			{
				pos = Vector(-344.86169433594, 2811.2490234375, 414.06427001953),
				ang = Angle(0, -141.7808380127, 0),
				fun = function( self )
					self:WaitPassenger( false );
					return 0;
				end
			},
			{
				pos = Vector(-447.32025146484, 2670.2661132812, 458.16796875),
				ang = Angle(0, -119.21332550049, 0),
				fun = function( self )
					self:GetPhysicsObject():EnableCollisions( false );
					self:Explode();
					return 0;
				end
			},
			{
				pos = Vector(-1037.6513671875, 1017.5170898438, 1518.9312744141),
				ang = Angle(0, -109.5975189209, 0),
				fun = function( self )
					return 0;
				end
			}
		},
		zp_hope = {
			{
				pos = Vector(-1108.3009033203, 766.85015869141, 1641.8055419922),
				ang = Angle(0, -30.417161941528, 0),
				fun = function( self )
					self:GetPhysicsObject():EnableCollisions( false );
					return 0;
				end
			},
			{
				pos = Vector(240.44323730469, 1.7935314178467, 1266.4819335938),
				ang = Angle(0, -40.817974090576, 0),
				fun = function( self )
					self:GetPhysicsObject():EnableCollisions( true );
					return 0;
				end
			},
			{
				pos = Vector(392.15707397461, -440, 1050),
				ang = Angle(0, -83.009536743164, 0),
				fun = function( self )
					self:WaitPassenger( true );
					return 30;
				end
			},
			{
				pos = Vector(1113.9666748047, -1291.3406982422, 1225.123046875),
				ang = Angle(0, -51.807300567627, 0),
				fun = function( self )
					self:WaitPassenger( false );
					self:GetPhysicsObject():EnableCollisions( false );
					self:Explode();
					return 0;
				end
			},
			{
				pos = Vector(1892.9188232422, -1910.9207763672, 1604.1993408203),
				ang = Angle(0, -40.425399780273, 0),
				fun = function( self )
					return 0;
				end
			}
		},
		zp_hide_arena = {
			{
				pos = Vector(2414.8571777344, -449.07989501953, 768.27954101562),
				ang = Angle(0, 169.00396728516, 0),
				fun = function( self )
					self:GetPhysicsObject():EnableCollisions( false );
					return 0;
				end
			},
			{
				pos = Vector(956.16723632812, 1378.8073730469, 659.28820800781),
				ang = Angle(0, 131.71835327148, 0),
				fun = function( self )
					self:GetPhysicsObject():EnableCollisions( true );
					return 0;
				end
			},
			{
				pos = Vector(340, 1450, 520),
				ang = Angle(0, 174.89059448242, 0),
				fun = function( self )
					self:WaitPassenger( true );
					return 30;
				end
			},
			{
				pos = Vector(-335.19259643555, 1537.5418701172, 424.75668334961),
				ang = Angle(0, -161.95320129395, 0),
				fun = function( self )
					self:WaitPassenger( false );
					return 0;
				end
			},
			{
				pos = Vector(-1217.4471435547, -311.83941650391, 541.00842285156),
				ang = Angle(0, -113.48189544678, 0),
				fun = function( self )
					self:GetPhysicsObject():EnableCollisions( false );
					self:Explode();
					return 0;
				end
			},
			{
				pos = Vector(-2117.9609375, -2186.1845703125, 638.33612060547),
				ang = Angle(0, -118.19165039062, 0),
				fun = function( self )
					return 0;
				end
			}
		},
		zp_tundra = {
			{
				pos = Vector(-1453.8887939453, -1733.9228515625, 1826.9755859375),
				ang = Angle(0, 40.616943359375, 0),
				fun = function( self )
					self:GetPhysicsObject():EnableCollisions( false );
					return 0;
				end
			},
			{
				pos = Vector(-252.75666809082, -444.45553588867, 789.91296386719),
				ang = Angle(0, 59.848598480225, 0),
				fun = function( self )
					self:GetPhysicsObject():EnableCollisions( true );
					return 0;
				end
			},
			{
				pos = Vector(234.37216186523, 362.89337158203, 662.00207519531),
				ang = Angle(0, 24.721544265747, 0),
				fun = function( self )
					return 0;
				end
			},
			{
				pos = Vector(800, 498.24932861328, 550),
				ang = Angle(0, 0.78027522563934, 0),
				fun = function( self )
					self:WaitPassenger( true );
					return 30;
				end
			},
			{
				pos = Vector(1141.3576660156, 344.62377929688, 548.14459228516),
				ang = Angle(0, -30.421855926514, 0),
				fun = function( self )
					self:WaitPassenger( false );
					self:GetPhysicsObject():EnableCollisions( false );
					return 0;
				end
			},
			{
				pos = Vector(2000, 117.01522064209, 1100),
				ang = Angle(0, -4.9106774330139, 0),
				fun = function( self )
					self:Explode();
					return 0;
				end
			}
		}
	};
	if (trace[game.GetMap()] == nil) then return false; end
	return trace[game.GetMap()];
end

MAP:Initialize();