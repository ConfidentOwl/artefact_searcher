extends VBoxContainer

class_name ItemActions

var item_link : ItemContayner = null 

@export var inventory_gui : Control 
var player_slots : PlayerSlots = null

@onready var drop_item: Button = $DropItem
@onready var use_item: Button = $UseItem
@onready var drop_item_all: Button = $DropItemAll
@onready var put_in_slot: Button = $PutInSlot
@onready var discharge: Button = $Discharge

@onready var put_on_weapon_1: Button = $"Put on Weapon 1"
@onready var put_on_weapon_2: Button = $"Put on Weapon 2"
@onready var put_on_weapon_3: Button = $"Put on Weapon 3"

@onready var remove_silenc: Button = $"Remove Silenc"
@onready var remove_scope: Button = $"Remove Scope"
@onready var remove_gp: Button = $"Remove GP"

var _in_inventory : bool = true 

func _ready() -> void:
	self.hide_actions()
	if inventory_gui is ItemInvetoryUIPlayer :
		player_slots = inventory_gui.player_slots

func show_ations(item : ItemContayner , pos :Vector2, in_inventory : bool ) -> void :
	_in_inventory =in_inventory
	item_link = item 
	self.top_level = true 
	self.global_position = pos
	self.show()
	if inventory_gui is ItemInvetoryUIPlayer :
		match item_link.item_type :
			Global.ITEM_TYPE.ammo :
				drop_item.show()
				drop_item_all.show()
			Global.ITEM_TYPE.weapon1 :
				drop_item.show()
				if in_inventory :
					put_in_slot.show()
			Global.ITEM_TYPE.weapon2 :
				drop_item.show()
				if in_inventory :
					put_in_slot.show()
			Global.ITEM_TYPE.weapon3 :
				drop_item.show()
				if in_inventory :
					put_in_slot.show()
			Global.ITEM_TYPE.consumer :
				drop_item.show()
				drop_item_all.show()
				use_item.show()
			Global.ITEM_TYPE.monster_part :
				drop_item.show()
				drop_item_all.show()
			Global.ITEM_TYPE.weapon_addon :
				drop_item.show()
				drop_item_all.show()
				if check_can_it_in_wpn1() and in_inventory:
					put_on_weapon_1.show()
			_:
				print("else")
	else :
		print("Item Actions not ready!")
		#match item_link.item_type :
			#Global.ITEM_TYPE.ammo :
				#drop_item.show()
				#drop_item_all.show()
			#Global.ITEM_TYPE.weapon1 :
				#drop_item.show()
			#Global.ITEM_TYPE.weapon2 :
				#drop_item.show()
			#Global.ITEM_TYPE.consumer :
				#drop_item.show()
				#drop_item_all.show()
				#use_item.show()
			#Global.ITEM_TYPE.weapon_addon :
				#drop_item.show()
				#drop_item_all.show()
				#if check_can_it_in_wpn1() and in_inventory:
					#put_on_weapon_1.show()
			#_:
				#print("else")

func hide_actions() -> void:
	self.hide()
	_in_inventory = false
	item_link = null
	drop_item.hide()
	drop_item_all.hide()
	use_item.hide()
	put_in_slot.hide()
	discharge.hide()
	put_on_weapon_1.hide()
	put_on_weapon_2.hide()
	put_on_weapon_3.hide()
	remove_scope.hide()
	remove_silenc.hide()
	remove_scope.hide()
	remove_gp.hide()
	
func _on_drop_item_button_down() -> void:
	if _in_inventory : 
		inventory_gui.drop_item()
	else :
		player_slots.drop_item(item_link)
	hide_actions()

func _on_drop_item_all_button_down() -> void:
	inventory_gui.drop_all_item()
	hide_actions()

func _on_use_item_button_down() -> void:
	inventory_gui.use_item()
	hide_actions()

func _on_put_in_slot_button_down() -> void:
	inventory_gui.put_weapon_in_slot_wpn()
	hide_actions()

func _on_put_on_weapon_1_button_down() -> void:
	inventory_gui.put_weapon_addon_in_wpn1()
	hide_actions()

func check_can_it_in_wpn1() ->bool:
	if !player_slots.weapon1_has :
		return false
	match item_link.addon_type:
		Global.WEAPON_ADDON_TYPE.silens:
			if !player_slots.weapon1.can_has_silenc :
				return false
			if player_slots.weapon1.has_silenc :
				return false
			if item_link.weapon_assept_list.has(player_slots.weapon1.item_name):
				return true
		Global.WEAPON_ADDON_TYPE.scope :
			if !player_slots.weapon1.can_has_scope :
				return false
			if player_slots.weapon1.has_scope :
				return false
			if item_link.weapon_assept_list.has(player_slots.weapon1.item_name):
				return true
		Global.WEAPON_ADDON_TYPE.gp :
			if !player_slots.weapon1.can_has_gp :
				return false
			if player_slots.weapon1.has_gp :
				return false
			if item_link.weapon_assept_list.has(player_slots.weapon1.item_name):
				return true
		_:
			printerr("Get undefine Weapon Addon type !!!")
			return false
	return false
