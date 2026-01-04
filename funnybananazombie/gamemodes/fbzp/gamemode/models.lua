MODELS = {};

MODELS.list = {};

function MODELS:Initialize()
	self:GetModelList();
end

function MODELS:GetModelList()
	self.list = {
		{
			id = 1,
			model = "models/mark2580/metro_conflict/trish_player.mdl",
			bodyGroups = "000",
			startHealth = 100,
			speed = 300,
			team = 1,
			name = "black1"
		},
		{
			id = 2,
			model = "models/player/zombies/zombie_guard.mdl",
			bodyGroups = "000",
			startHealth = 300,
			speed = 500,
			team = 2,
		},
		{
			id = 3,
			model = "models/player/pizzaroll/l4dhunter.mdl",
			bodyGroups = "000",
			startHealth = 300,
			speed = 500,
			team = 2,
		},
		{
			id = 4,
			model = "models/kuma96/2b/2b_pm.mdl",
			bodyGroups = "000",
			startHealth = 300,
			speed = 500,
			team = 2,
		},
		{
			id = 5,
			model = "models/player/kuristaja/l4d2/spitter/spitter.mdl",
			bodyGroups = "000",
			startHealth = 300,
			speed = 500,
			team = 2,
		},
		{
			id = 6,
			model = "models/players/mj_dbd_qk_playermodel.mdl",
			bodyGroups = "000",
			startHealth = 300,
			speed = 500,
			team = 2,
		},
		{
			id = 7,
			model = "models/payday2/units/murkywater_bulldozer_player.mdl",
			bodyGroups = "000",
			startHealth = 300,
			speed = 500,
			team = 2,
		},
		{
			id = 8,
			model = "models/payday2/units/murkywater_captain_guard_player.mdl",
			bodyGroups = "000",
			startHealth = 300,
			speed = 500,
			team = 2,
		},
		{
			id = 9,
			model = "models/payday2/units/murkywater_cloaker_player.mdl",
			bodyGroups = "000",
			startHealth = 300,
			speed = 500,
			team = 2,
		},
		{
			id = 10,
			model = "models/payday2/units/murkywater_swat_fbi_player.mdl",
			bodyGroups = "000",
			startHealth = 300,
			speed = 500,
			team = 2,
		}
	}
end

function MODELS:GetModel( id )
	for k,v in pairs( MODELS.list ) do
		if ( v.id == id ) then
			return v;
		end
	end
	return MODELS.list[1];
end

MODELS:Initialize();