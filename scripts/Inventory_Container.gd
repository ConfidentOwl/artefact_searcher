extends StaticBody3D

class_name Inventory_Container

@onready var inventroy_keeper: Inventroy_Keeper = $Inventroy_Keeper
@export var links_to_items_to_add : Array[String]
@export var _need_add_item : bool  = true 

func _ready() -> void:
	if _need_add_item :
		for i in links_to_items_to_add :# add items initioal!
			inventroy_keeper.add_item(load(i).instantiate().item_conteiner)
		_need_add_item = false
