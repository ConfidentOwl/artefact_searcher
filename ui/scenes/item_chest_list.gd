extends Control

class_name Item_Chest_List

@onready var item_actions: ItemActions = $ItemActions
@onready var item_list: ItemList = $ItemList
@onready var item_list_chest: ItemList = $ItemList2

var curent_sorting : Global.SORTING = Global.SORTING.all

var _array_link : Array[ItemContayner]
var _sorting_id_to_id : Dictionary 

var _array_link_chest : Array[ItemContayner]
var _sorting_id_to_id_chest : Dictionary 

@export var invetory_keeper :  Inventroy_Keeper
var iventory_chest_keeper : Inventroy_Keeper

func update_item_list() -> void:
	var newList : Array[ItemContayner] = invetory_keeper.MainList
	_array_link = newList.duplicate(true)
	var newList_chest : Array[ItemContayner] = iventory_chest_keeper.MainList
	_array_link_chest = newList_chest.duplicate(true)
	item_list.clear()
	item_list_chest.clear()
	match curent_sorting :
		Global.SORTING.all :
			InventoryApi._sorte_item_all(_array_link,_sorting_id_to_id,item_list)
			InventoryApi._sorte_item_all(_array_link_chest,_sorting_id_to_id_chest,item_list_chest)
		Global.SORTING.wpn :
			InventoryApi._sorte_item_wpn(_array_link,_sorting_id_to_id,item_list)
			InventoryApi._sorte_item_wpn(_array_link_chest,_sorting_id_to_id_chest,item_list_chest)
		Global.SORTING.ammo :
			InventoryApi._sorte_item_ammo(_array_link,_sorting_id_to_id,item_list)
			InventoryApi._sorte_item_ammo(_array_link_chest,_sorting_id_to_id_chest,item_list_chest)
		Global.SORTING.consumer :
			InventoryApi._sorte_item_cons(_array_link,_sorting_id_to_id,item_list)
			InventoryApi._sorte_item_cons(_array_link_chest,_sorting_id_to_id_chest,item_list_chest)
		Global.SORTING.monster_part :
			InventoryApi._sorte_item_monster_part(_array_link,_sorting_id_to_id,item_list)
			InventoryApi._sorte_item_monster_part(_array_link_chest,_sorting_id_to_id_chest,item_list_chest)

func shou_gui(_iventory_chest_keeper : Inventroy_Keeper) -> void :
	iventory_chest_keeper = _iventory_chest_keeper
	update_item_list()
	self.show()

func hide_gui() -> void:
	item_list.clear()
	item_actions.hide_actions()
	self.hide()

func _on_item_list_item_selected(index: int) -> void:
	var curent_item : ItemContayner = InventoryApi.get_real_id_from_sorted_id(_array_link,_sorting_id_to_id,item_list)
	if curent_item.item_stakable :
		if curent_item.item_count > curent_item.item_stack_amount:
			var copy_curent_item : ItemContayner = curent_item.duplicate()
			curent_item.item_count -= curent_item.item_stack_amount
			copy_curent_item.item_count = curent_item.item_stack_amount
			iventory_chest_keeper.add_item(copy_curent_item)
		else :
			iventory_chest_keeper.add_item(curent_item)
			invetory_keeper.remove_item(curent_item)
	else :
		iventory_chest_keeper.add_item(curent_item)
		invetory_keeper.remove_item(curent_item)
	update_item_list()

func _on_item_list_2_item_selected(index: int) -> void:
	var curent_item : ItemContayner = InventoryApi.get_real_id_from_sorted_id(_array_link_chest,_sorting_id_to_id_chest,item_list_chest)
	if curent_item.item_stakable :
		if curent_item.item_count > curent_item.item_stack_amount:
			var copy_curent_item : ItemContayner = curent_item.duplicate()
			curent_item.item_count -= curent_item.item_stack_amount
			copy_curent_item.item_count = curent_item.item_stack_amount
			invetory_keeper.add_item(copy_curent_item)
		else :
			invetory_keeper.add_item(curent_item)
			iventory_chest_keeper.remove_item(curent_item)
	else :
		invetory_keeper.add_item(curent_item)
		iventory_chest_keeper.remove_item(curent_item)
	update_item_list()

func _on_shou_all_button_down() -> void:
	curent_sorting = Global.SORTING.all
	update_item_list()

func _on_shou_wpn_button_down() -> void:
	curent_sorting = Global.SORTING.wpn
	update_item_list()

func _on_shou_cons_button_down() -> void:
	curent_sorting = Global.SORTING.consumer
	update_item_list()

func _on_shou_ammo_button_down() -> void:
	curent_sorting = Global.SORTING.ammo
	update_item_list()

func _on_shou_monster_part_button_down() -> void:
	curent_sorting = Global.SORTING.monster_part
	update_item_list()
