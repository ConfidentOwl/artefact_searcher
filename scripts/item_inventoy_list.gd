extends Control

class_name ItemInvetoryUIPlayer

@onready var player_item_slot_ui_1: TextureButton = $ItemSlots/PlayerItemSlotUI1
@onready var player_item_slot_ui_1_text: Label = $ItemSlots/PlayerItemSlotUI1/PlayerItemSlotUI1Text
@onready var player_item_slot_ui_2: TextureButton = $ItemSlots/PlayerItemSlotUI2
@onready var player_item_slot_ui_2_text: Label = $ItemSlots/PlayerItemSlotUI2/PlayerItemSlotUI2Text
@onready var player_item_slot_ui_3: TextureButton = $ItemSlots/PlayerItemSlotUI3
@onready var player_item_slot_ui_3_text: Label = $ItemSlots/PlayerItemSlotUI3/PlayerItemSlotUI3Text

var mouse_in_player_item_slot_ui_1 :bool = false
var mouse_in_player_item_slot_ui_2 :bool = false
var mouse_in_player_item_slot_ui_3 :bool = false

@onready var item_droper: Node3D = $"../../CameraController/Recoil/Camera3D/ItemDroper"

@export var invetory_keeper :  Inventroy_Keeper
@export var player_slots : PlayerSlots
@export var effectupdate :EffectsUpdate 
@onready var item_list: ItemList = $ItemList
@onready var player: Player = $"../.."

@onready var item_actions: ItemActions = $ItemActions

var curent_sorting : Global.SORTING = Global.SORTING.all

var _array_link : Array[ItemContayner]
var _sorting_id_to_id : Dictionary 

func update_item_list() -> void:
	var newList : Array[ItemContayner] = invetory_keeper.MainList
	_array_link = newList
	item_list.clear()
	clear_buttom_slot(player_item_slot_ui_1,player_item_slot_ui_1_text)
	clear_buttom_slot(player_item_slot_ui_2,player_item_slot_ui_2_text)
	clear_buttom_slot(player_item_slot_ui_3,player_item_slot_ui_3_text)
	if player_slots.weapon1_has :
		update_buttom_slot(player_slots.weapon1,player_item_slot_ui_1,player_item_slot_ui_1_text)
	if player_slots.weapon2_has :
		update_buttom_slot(player_slots.weapon2,player_item_slot_ui_2,player_item_slot_ui_2_text)
	if player_slots.weapon3_has :
		update_buttom_slot(player_slots.weapon3,player_item_slot_ui_3,player_item_slot_ui_3_text)
	match curent_sorting :
		Global.SORTING.all :
			InventoryApi._sorte_item_all(_array_link,_sorting_id_to_id,item_list)
		Global.SORTING.wpn :
			InventoryApi._sorte_item_wpn(_array_link,_sorting_id_to_id,item_list)
		Global.SORTING.ammo :
			InventoryApi._sorte_item_ammo(_array_link,_sorting_id_to_id,item_list)
		Global.SORTING.consumer :
			InventoryApi._sorte_item_cons(_array_link,_sorting_id_to_id,item_list)
		Global.SORTING.monster_part :
			InventoryApi._sorte_item_monster_part(_array_link,_sorting_id_to_id,item_list)


func _input(event: InputEvent) -> void:
	var selected :PackedInt32Array= item_list.get_selected_items()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if player_slots.weapon1_has and mouse_in_player_item_slot_ui_1:
			item_actions.show_ations(player_slots.weapon1, event.position ,false )
		if player_slots.weapon2_has and mouse_in_player_item_slot_ui_2:
			item_actions.show_ations(player_slots.weapon2, event.position ,false )
		if player_slots.weapon3_has and mouse_in_player_item_slot_ui_3:
			item_actions.show_ations(player_slots.weapon3, event.position ,false )
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:#DOUBLE CLICK
		if player_slots.weapon1_has and mouse_in_player_item_slot_ui_1:#Put item to main invenotory
			if player._curent_wpn_hud_scene != null and player._curent_wpn_hud_scene._item_conteiner_link.item_type == Global.ITEM_TYPE.weapon1:
				player._curent_wpn_hud_scene.queue_free()
			player_slots.weapon1_has = false
			invetory_keeper.add_item(player_slots.weapon1.duplicate())
			clear_buttom_slot(player_item_slot_ui_1,player_item_slot_ui_1_text)
			player_slots.weapon1 = null
			player.wpn_down()
			update_item_list()
		if player_slots.weapon2_has and mouse_in_player_item_slot_ui_2:#Put item to main invenotory
			if player._curent_wpn_hud_scene != null and player._curent_wpn_hud_scene._item_conteiner_link.item_type == Global.ITEM_TYPE.weapon2:
				player._curent_wpn_hud_scene.queue_free()
			player_slots.weapon2_has = false
			invetory_keeper.add_item(player_slots.weapon2.duplicate())
			clear_buttom_slot(player_item_slot_ui_2,player_item_slot_ui_2_text)
			player_slots.weapon2 = null
			player.wpn_down()
			update_item_list()
		if player_slots.weapon3_has and mouse_in_player_item_slot_ui_3:#Put item to main invenotory
			if player._curent_wpn_hud_scene != null and player._curent_wpn_hud_scene._item_conteiner_link.item_type == Global.ITEM_TYPE.weapon3:
				player._curent_wpn_hud_scene.queue_free()
			player_slots.weapon3_has = false
			invetory_keeper.add_item(player_slots.weapon3.duplicate())
			clear_buttom_slot(player_item_slot_ui_3,player_item_slot_ui_3_text)
			player_slots.weapon3 = null
			player.wpn_down()
			update_item_list()
	if selected.size() == 1:
		if event.is_action_pressed("UIItemDrop"):#Drop some item
			drop_item()
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT :
			item_actions.show_ations(get_real_id_from_sorted_id(), event.position , true )

func shou_gui() ->void :
	update_item_list()
	self.show()

func hide_gui() -> void:
	item_list.clear()
	item_actions.hide_actions()
	clear_buttom_slot(player_item_slot_ui_1,player_item_slot_ui_1_text)
	self.hide()
	
func update_buttom_slot(slot :ItemContayner ,buton :TextureButton,text_button :Label) ->void:
	buton.texture_normal = slot.item_image
	text_button.text = slot.item_name

func clear_buttom_slot(buton :TextureButton,text_button :Label) -> void:
	buton.texture_normal = Texture2D.new()
	text_button.text = ""

func _on_item_list_item_activated(index: int) -> void:
	var real_link : ItemContayner = get_real_id_drom_id(index)
	match real_link.item_type :
		Global.ITEM_TYPE.weapon1:
			put_weapon_in_slot_wpn_1()
		Global.ITEM_TYPE.weapon2:
			put_weapon_in_slot_wpn_2()
		Global.ITEM_TYPE.weapon3:
			put_weapon_in_slot_wpn_3()
		#armor,
		#consumer,
		#quest,
		Global.ITEM_TYPE.consumer :
			use_item() 
		#defalult
		_:
			print("Erore!!!")

func drop_item() -> ItemContayner :
	var link : ItemContayner = get_real_id_from_sorted_id()
	var path : String= link.item_scene
	if ResourceLoader.exists(path) :
		var drop_item : ItemScript
		if  link.item_stakable and  link.item_stack_amount < link.item_count:
			drop_item  = load(link.item_scene).instantiate()
			drop_item.item_conteiner.item_count = link.item_stack_amount 
			link.item_count -= link.item_stack_amount 
			Global.curent_world.add_child(drop_item)
			drop_item.global_position = item_droper.global_position
			update_item_list()
			return link
		else :
			drop_item  = load(link.item_scene).instantiate()
			Global.curent_world.add_child(drop_item)
			drop_item.global_position = item_droper.global_position
			drop_item.item_conteiner = link.duplicate()
			invetory_keeper.remove_item(link)
			update_item_list()
			return null
	return null

func drop_item_by_link(link : ItemContayner) -> ItemContayner :
	var drop_item : ItemScript
	if  link.item_stakable and  link.item_stack_amount < link.item_count:
		drop_item  = load(link.item_scene).instantiate()
		drop_item.item_conteiner.item_count = link.item_stack_amount 
		link.item_count -= link.item_stack_amount 
		Global.curent_world.add_child(drop_item)
		drop_item.global_position = item_droper.global_position
		update_item_list()
		return link
	else :
		drop_item = load(link.item_scene).instantiate()
		Global.curent_world.add_child(drop_item)
		drop_item.global_position = item_droper.global_position
		drop_item.item_conteiner = link.duplicate()
		invetory_keeper.remove_item(link)
		update_item_list()
		return null
	return null

func drop_all_item() -> void:
	var link : ItemContayner = drop_item()
	while link != null :
		link = drop_item_by_link(link)

func _on_player_item_slot_ui_1_mouse_entered() -> void:
	mouse_in_player_item_slot_ui_1 = true

func _on_player_item_slot_ui_1_mouse_exited() -> void:
	mouse_in_player_item_slot_ui_1 = false

func _on_player_item_slot_ui_2_mouse_entered() -> void:
	mouse_in_player_item_slot_ui_2 = true

func _on_player_item_slot_ui_2_mouse_exited() -> void:
	mouse_in_player_item_slot_ui_2 = false

func _on_player_item_slot_ui_3_mouse_entered() -> void:
	mouse_in_player_item_slot_ui_3 = true

func _on_player_item_slot_ui_3_mouse_exited() -> void:
	mouse_in_player_item_slot_ui_3 = false

func consume_one_item(curent_item :ItemContayner) ->void:
	var index : int = _array_link.find(curent_item)
	if !curent_item.item_stakable :
		_array_link.remove_at(index)
		return
	elif curent_item.item_count ==1 :
		_array_link.remove_at(index)
		return
	else :
		curent_item.item_count -=1

func use_item() ->void:
	var selected_item :ItemContayner = get_real_id_from_sorted_id()
	effectupdate.add_efects(selected_item)
	consume_one_item(selected_item)
	update_item_list()

func put_weapon_in_slot_wpn() -> void:
	var link : ItemContayner = get_real_id_from_sorted_id()
	match link.item_type:
		Global.ITEM_TYPE.weapon1:
			put_weapon_in_slot_wpn_1()
		Global.ITEM_TYPE.weapon2:
			put_weapon_in_slot_wpn_2()
		_:
			printerr("Get unsupert put in slot item !!!! --Script item_inventoty_list.gd")

func put_weapon_in_slot_wpn_1() -> void :
	var link : ItemContayner = get_real_id_from_sorted_id()
	player_slots.weapon1_has = true
	player_slots.weapon1 = link.duplicate()
	update_buttom_slot(player_slots.weapon1,player_item_slot_ui_1,player_item_slot_ui_1_text)
	consume_one_item(link)
	update_item_list()

func put_weapon_in_slot_wpn_2() -> void :
	var link : ItemContayner = get_real_id_from_sorted_id()
	player_slots.weapon2_has = true
	player_slots.weapon2 = link.duplicate()
	update_buttom_slot(player_slots.weapon2,player_item_slot_ui_2,player_item_slot_ui_2_text)
	consume_one_item(link)
	update_item_list()

func put_weapon_in_slot_wpn_3() -> void :
	var link : ItemContayner = get_real_id_from_sorted_id()
	player_slots.weapon3_has = true
	player_slots.weapon3 = link.duplicate()
	update_buttom_slot(player_slots.weapon3,player_item_slot_ui_3,player_item_slot_ui_3_text)
	consume_one_item(link)
	update_item_list()

func put_weapon_addon_in_wpn1() ->void:
	var link : ItemContayner = _array_link[item_list.get_selected_items()[0]]
	match link.addon_type:
		Global.WEAPON_ADDON_TYPE.silens:
			player_slots.weapon1.has_silenc = true
		Global.WEAPON_ADDON_TYPE.scope :
			player_slots.weapon1.has_scope = true
		Global.WEAPON_ADDON_TYPE.gp :
			player_slots.weapon1.has_gp = true
		_:
			printerr("Get undefine Weapon Addon type !!!")
	consume_one_item(link)
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

func get_real_id_from_sorted_id() -> ItemContayner :
	return _array_link[_sorting_id_to_id.find_key(item_list.get_selected_items()[0])]
	
func get_real_id_drom_id(id:int) -> ItemContayner:
	return _array_link[_sorting_id_to_id.find_key(id)]

func _on_shou_monster_part_button_down() -> void:
	curent_sorting = Global.SORTING.monster_part
	update_item_list()
