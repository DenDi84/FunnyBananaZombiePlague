-- ENT.Base = "base_entity"
-- ENT.Type = "point"

ENT.Type = "anim";
ENT.Base = "base_anim";

ENT.setup = {
	spawndelay = 4
};

ENT.round = {
	type = "ready",
	name = "Подготовка",
	time = 20,
	sound = false,
	length = 0
};

ENT.list = {
	{
		type = "infection",
		name = "Инфекция",
		time = 210,
		sound = "end3",
		length = 0
	},
	{
		type = "survival",
		name = "Выживание",
		time = 120,
		sound = "fail1",
		length = 0
	},
	{
		type = "invasion",
		name = "Нашествие",
		time = 180,
		sound = "fail3",
		length = 0
	},
	{
		type = "massinfection",
		name = "Массовая инфекция",
		time = 180,
		sound = "end3",
		length = 0
	},
	{
		type = "demogorg",
		name = "Демогорг",
		time = 240,
		sound = "end3",
		length = 0
	},
	{
		type = "hero",
		name = "Герой",
		time = 240,
		sound = "end3",
		length = 0
	},
	{
		type = "battle",
		name = "Мясорубка",
		time = 300,
		sound = "end3",
		length = 0
	},
	{
		type = "escape",
		name = "Эвакуация",
		time = 320,
		sound = "end3",
		length = 0
	}
};

ENT.sounds = {
	timeout = "win2",
	human_win = "win3",
	zombie_win = "end1",
	equality = "none1"
};
ENT.roundparam = {
	timeout = {
		finish = "Время вышло!",
		sound = "win2"
	},
	human_win = {
		finish = "<strong class='color-blue'>Людишки</strong> победили!",
		sound = "win3"
	},
	zombie_win = {
		finish = "<strong class='color-green'>Зомби</strong> захватили мир!",
		sound = "end1"
	},
	equality = {
		finish = "Взаимное уничтожение!",
		sound = "none1"
	}
};

ENT.change = {
	demogorg = NULL,
	infection = NULL,
	hero = NULL,
	battle = false
};