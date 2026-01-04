local knive_sound = {
	{ name = "csgo_knife.Deploy", channel = CHAN_WEAPON, volume = 0.4, level = 65, sound = "csgo_knife/knife_deploy1.wav"},
	{ name = "csgo_knife.Hit", channel = CHAN_WEAPON, volume = 1.0, level = 65, sound = { "csgo_knife/knife_hit1.wav", "csgo_knife/knife_hit2.wav", "csgo_knife/knife_hit3.wav", "csgo_knife/knife_hit4.wav" }},
	{ name = "csgo_knife.HitWall", channel = CHAN_WEAPON, volume = 1.0, level = 65, sound = { "csgo_knife/knife_hit_01.wav", "csgo_knife/knife_hit_02.wav", "csgo_knife/knife_hit_03.wav", "csgo_knife/knife_hit_04.wav", "csgo_knife/knife_hit_05.wav" }},
	{ name = "csgo_knife.HitWall_old", channel = CHAN_WEAPON, volume = 1.0, level = 65, sound = { "csgo_knife/knife_hitwall1.wav", "csgo_knife/knife_hitwall2.wav", "csgo_knife/knife_hitwall3.wav", "csgo_knife/knife_hitwall4.wav" }},
	{ name = "csgo_knife.Slash", channel = CHAN_WEAPON, volume = {0.5, 1.0}, pitch = {97, 105}, level = 65, sound = { "csgo_knife/knife_slash1.wav", "csgo_knife/knife_slash2.wav" }},
	{ name = "csgo_knife.Slash_old", channel = CHAN_WEAPON, volume = {0.5, 1.0}, pitch = {97, 105}, level = 65, sound = { "csgo_knife/knife_slash1_old.wav", "csgo_knife/knife_slash2_old.wav" }},
	{ name = "csgo_knife.Stab", channel = CHAN_WEAPON, volume = 1.0, level = 65, sound = "csgo_knife/knife_stab.wav"}
};
for k,v in pairs(knive_sound) do
	sound.Add( v );
	util.PrecacheSound( v.name );
end

local zombieSound = {
	{ name = "zombie_noise", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "weapons/flaregun/burn.wav"},
	{ name = "zombie_slick", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "ambient/fire/gascan_ignite1.wav"},
	{ name = "zombie_fire", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "ambient/fire/firebig.wav"},
	{ name = "zombie_jump", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "npc/headcrab_poison/ph_jump1.wav"},
	{ name = "zombie_swing", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "weapons/iceaxe/iceaxe_swing1.wav"},
	{ name = "zombie_explode", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "weapons/airboat/airboat_gun_energy1.wav"},
	{ name = "zombie_explode_fire", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "weapons/explode3.wav"},
	{ name = "zombie_on_fire", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "ambient/fire/ignite.wav"},
	{ name = "zombie_light_on", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "items/flashlight1.wav"},
	{ name = "zombie_spark", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "weapons/stunstick/spark1.wav"},
	{ name = "zombie_test", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "vo/NovaProspekt/al_room1_lights.wav"},
	{ name = "aheli_rotor", channel = CHAN_AUTO, volume = 0.8, level = 80, sound = "npc/attack_helicopter/aheli_rotor_loop1.wav"},
	{ name = "escape_alarm", channel = CHAN_AUTO, volume = 0.8, level = 80, sound = "ambient/alarms/alarm_citizen_loop1.wav"},
	{ name = "escape_explode", channel = CHAN_AUTO, volume = 0.8, level = 80, sound = "ambient/explosions/explode_1.wav"},
};
for k,v in pairs(zombieSound) do
	sound.Add( v );
	util.PrecacheSound( v.name );
end

local roundsound = {
	{ name = "end1", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "end1.wav"},
	{ name = "end2", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "end2.wav"},
	{ name = "end3", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "end3.wav"},
	{ name = "fail1", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "fail1.wav"},
	{ name = "fail2", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "fail2.wav"},
	{ name = "fail3", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "fail3.wav"},
	{ name = "fail4", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "fail4.wav"},
	{ name = "fail5", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "fail5.wav"},
	{ name = "fail6", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "fail6.wav"},
	{ name = "none1", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "none1.wav"},
	{ name = "win1", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "win1.wav"},
	{ name = "win2", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "win2.wav"},
	{ name = "win3", channel = CHAN_STATIC, volume = 0.8, level = 80, sound = "win3.wav"},
	{ name = "nightvision", channel = CHAN_AUTO, volume = 0.8, level = 80, sound = "nightvision.wav"},
};
for k,v in pairs(roundsound) do
	sound.Add( v );
	util.PrecacheSound( v.name );
end
-- if (CLIENT) then
-- 	print("start");
-- 	LocalPlayer():EmitSound("zombie_noise");
-- 	timer.Create("StopSpecAttackSound", 10, 1, function()
-- 		LocalPlayer():StopSound( "zombie_noise" );
-- 	end );
-- end

-- ambient/atmosphere/noise2.wav 
-- ambient/fire/mtov_flame2.wav - приглушенный как будто в мешок что-то кладут
-- ambient/fire/ignite.wav - взрыв с шипением ( ambient/fire/gascan_ignite1.wav - без шипения )


local shibe_weapon_pack = {
	{name = "swp_mp5.bolt",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/mp5/bolt.wav"},
	{name = "swp_mp5.clipin",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/mp5/clipin.wav"},
	{name = "swp_mp5.clipout",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/mp5/clipout.wav"},
	{name = "swp_scar.bolt",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/scar/bolt.wav"},
	{name = "swp_scar.clipin",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/scar/clipin.wav"},
	{name = "swp_scar.clipout",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/scar/clipout.wav"},
	{name = "swp_scar.draw",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/scar/draw.wav"},
	{name = "swp_ak74.bolt",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/ak74/bolt.wav"},
	{name = "swp_ak74.clipin",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/ak74/clipin.wav"},
	{name = "swp_ak74.clipout",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/ak74/clipout.wav"},
	{name = "swp_mp7.bolt",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/mp7/bolt.wav"},
	{name = "swp_mp7.cliphit",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/mp7/cliphit.wav"},
	{name = "swp_mp7.clipin",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/mp7/clipin.wav"},
	{name = "swp_mp7.clipout",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/mp7/clipout.wav"},
	{name = "swp_deagle.slide",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/deagle/slide.wav"},
	{name = "swp_deagle.clipin",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/deagle/clipin.wav"},
	{name = "swp_deagle.clipout",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/deagle/clipout.wav"},
	{name = "swp_sg550.bolt",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/sg550/bolt.wav"},
	{name = "swp_sg550.clipin",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/sg550/clipin.wav"},
	{name = "swp_sg550.clipout",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/sg550/clipout.wav"},
	{name = "swp_mk18.bolt",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/mk18/bolt.wav"},
	{name = "swp_mk18.clipin",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/mk18/clipin.wav"},
	{name = "swp_mk18.clipout",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/mk18/clipout.wav"},
	{name = "swp_p228.clipin",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/p228/clipin.wav"},
	{name = "swp_p228.clipout",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/p228/clipout.wav"},
	{name = "swp_p228.slide",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/p228/slide.wav"},
	{name = "swp_p228.slideback",channel = CHAN_STATIC,volume = 1.0,sound = "swp_weapons/p228/slideback.wav"}
};

for k,v in pairs(shibe_weapon_pack) do
	sound.Add( v );
	util.PrecacheSound( v.name );
end

local tbl = {"Magnum.ClipOut","weapons/deagle_beast/de_clipout.wav",
"Magnum.ClipIn","weapons/deagle_beast/de_clipin.wav",
"Magnum.SlideForward","weapons/deagle_beast/de_slideback.wav",
"Magnum.Deploy","weapons/deagle_beast/de_deploy.wav",
"Rifle.FullAutoButton","weapons/m4a1_beast/rifle_fullautobutton_1.wav",
"Rifle.ClipOut","weapons/m4a1_beast/rifle_clip_out_1.wav",
"Rifle.Clipin","weapons/m4a1_beast/rifle_clip_in_1.wav",
"Rifle.ClipLocked","weapons/m4a1_beast/rifle_clip_locked_1.wav",
"AK47.SlideBack","weapons/ak47_beast/rifle_slideback.wav",
"AK47.ClipIn","weapons/ak47_beast/rifle_clip_in_1.wav",
"AK47.SlideForward","weapons/ak47_beast/rifle_slideforward.wav",
"AK47.Deploy","weapons/ak47_beast/rifle_deploy_1.wav"
}
for i = 1,#tbl,2 do
	sound.Add(
	{
		name = tbl[i],
		channel = CHAN_WEAPON,
		volume = 1.0,
		soundlevel = 80,
		sound = tbl[i+1]
	})
end




-- sound.Add( { name = "csgo_knife.Deploy", channel = CHAN_WEAPON, volume = 0.4, level = 65, sound = "csgo_knife/knife_deploy1.wav"} )
-- sound.Add( { name = "csgo_knife.Hit", channel = CHAN_WEAPON, volume = 1.0, level = 65, sound = { "csgo_knife/knife_hit1.wav", "csgo_knife/knife_hit2.wav", "csgo_knife/knife_hit3.wav", "csgo_knife/knife_hit4.wav" }} )
-- sound.Add( { name = "csgo_knife.HitWall", channel = CHAN_WEAPON, volume = 1.0, level = 65, sound = { "csgo_knife/knife_hit_01.wav", "csgo_knife/knife_hit_02.wav", "csgo_knife/knife_hit_03.wav", "csgo_knife/knife_hit_04.wav", "csgo_knife/knife_hit_05.wav" }} )
-- sound.Add( { name = "csgo_knife.HitWall_old", channel = CHAN_WEAPON, volume = 1.0, level = 65, sound = { "csgo_knife/knife_hitwall1.wav", "csgo_knife/knife_hitwall2.wav", "csgo_knife/knife_hitwall3.wav", "csgo_knife/knife_hitwall4.wav" }} )
-- sound.Add( { name = "csgo_knife.Slash", channel = CHAN_WEAPON, volume = {0.5, 1.0}, pitch = {97, 105}, level = 65, sound = { "csgo_knife/knife_slash1.wav", "csgo_knife/knife_slash2.wav" }} )
-- sound.Add( { name = "csgo_knife.Slash_old", channel = CHAN_WEAPON, volume = {0.5, 1.0}, pitch = {97, 105}, level = 65, sound = { "csgo_knife/knife_slash1_old.wav", "csgo_knife/knife_slash2_old.wav" }} )
-- sound.Add( { name = "csgo_knife.Stab", channel = CHAN_WEAPON, volume = 1.0, level = 65, sound = "csgo_knife/knife_stab.wav"} )
