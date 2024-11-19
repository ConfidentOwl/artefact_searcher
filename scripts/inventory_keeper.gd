extends Node

class_name Inventroy_Keeper

@export var ItemInventoryList : ItemInvetoryUIPlayer

var _weight :float = 0

@export var MainList : Array[ItemContayner]

func _ready() -> void:
	pass # Replace with function body.

func add_item(item :ItemContayner) -> void:
	if item.item_stakable :
		add_stakable(item)
	else: 
		MainList.append(item)

func add_stakable(item :ItemContayner) -> void:
	for i in MainList:
		if i.item_name == item.item_name:
			i.item_count +=item.item_count
			return
	MainList.append(item)

func update_weight() ->void :
	for i : ItemContayner in MainList :
		_weight+=(i.item_weight*i.item_count)

func remove_item(curent_item :ItemContayner) -> void :
	MainList.erase(curent_item)
	
func get_ammo_amount(calib :Global.CALIBRS) -> int :
	for i in MainList:
		if i.item_type != Global.ITEM_TYPE.ammo :
			continue
		if i.ammo_calibr == calib:
			return i.item_count
	return 0

func remove_ammo_amount(calib :Global.CALIBRS, ammount : int ) -> void:
	for i : ItemContayner in MainList:
		if i.item_type != Global.ITEM_TYPE.ammo :
			continue
		if i.ammo_calibr == calib:
			i.item_count -= ammount 

func set_ammo_ammoount(calib :Global.CALIBRS, ammount : int) -> void :
	for i : ItemContayner in MainList:
		if i.item_type != Global.ITEM_TYPE.ammo :
			continue
		if i.ammo_calibr == calib:
			if ammount == 0:
				remove_item(i)
				return
			i.item_count = ammount
			return 
