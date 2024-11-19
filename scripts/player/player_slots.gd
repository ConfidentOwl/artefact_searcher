extends Node

class_name PlayerSlots

@onready var inventroy_keeper: Inventroy_Keeper = $"../Inventroy_Keeper"
@onready var item_inventoy_list: ItemInvetoryUIPlayer = $"../Control/ItemInventoyList"
@onready var player: Player = $".."


var weapon1: ItemContayner = null
var weapon1_has : bool = false
var weapon2: ItemContayner = null
var weapon2_has :bool = false
var weapon3: ItemContayner = null
var weapon3_has: bool = false
var armor :ItemContayner = null
var armor_has :bool = false

# w1 - 0  w2 - 1  w3 -2 armor -3


func drop_item(item_link) -> void :
	if item_link == weapon1:
		drop_item_slot(weapon1)
		weapon1_has = false
		check_for_drop_from_hand(0)
	elif item_link == weapon2:
		drop_item_slot(weapon2)
		weapon2_has = false
		check_for_drop_from_hand(1)
	elif item_link == weapon3:
		drop_item_slot(weapon3)
		weapon3_has = false
		check_for_drop_from_hand(2)
	elif item_link == armor:
		drop_item_slot(armor)
		armor_has = false


func drop_item_slot(item_to_drop : ItemContayner) -> void :
	var drop_item :ItemScript= load(item_to_drop.item_scene).instantiate()
	Global.curent_world.add_child(drop_item)
	drop_item.global_position = item_inventoy_list.player.ITEMDROPER.global_position
	drop_item.item_conteiner = item_to_drop.duplicate() 
	item_to_drop = null
	item_inventoy_list.update_item_list()
	return 

func check_for_drop_from_hand(wpn_number : int ) -> void :
	if player._curent_wpn_hud_scene == null:
		item_inventoy_list.update_item_list()
		return
	if player._curent_wpn_hud_scene._item_conteiner_link.item_type == Global.ITEM_TYPE.weapon1 and wpn_number == 0 :
		player.wpn_down()
		player._curent_wpn_hud_scene.queue_free()
	if player._curent_wpn_hud_scene._item_conteiner_link.item_type == Global.ITEM_TYPE.weapon2 and wpn_number == 1 :
		player.wpn_down()
		player._curent_wpn_hud_scene.queue_free()
	if player._curent_wpn_hud_scene._item_conteiner_link.item_type == Global.ITEM_TYPE.weapon3 and wpn_number == 2 :
		player.wpn_down()
		player._curent_wpn_hud_scene.queue_free()
	item_inventoy_list.update_item_list()
