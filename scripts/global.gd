extends Node

var debug_panel_player : DebugPanelPlayer
var main_character : Player
var curent_world : Node3D

# Confige 
var max_fps = 240

enum SORTING 
{
	all,
	wpn,
	ammo,
	consumer,
	monster_part
}

enum ITEM_TYPE
{
	weapon1,
	weapon2,
	weapon3,
	ammo,
	armor,
	consumer,
	quest,
	defalult,
	weapon_addon,
	monster_part
}

# B- base ,A-armor break , e -exposove
enum CALIBRS
{
	vog_25,
	b_762x39,
	a_762x39,
	b_9x19,
	a_9x19,
	b_12x70,
	a_12x70
}

enum WEAPON_CALIBR
{
	vog_25,
	w_762x39,
	w_545x39,
	w_556x39,
	w_9x19,
	w_12x70
}

enum WEAPON_ADDON_TYPE 
{
	silens,
	scope,
	gp
}
func _init() -> void:
	Engine.max_fps = max_fps
