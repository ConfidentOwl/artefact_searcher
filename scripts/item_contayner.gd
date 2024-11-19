extends Node

class_name ItemContayner

@export var item_type : Global.ITEM_TYPE = Global.ITEM_TYPE.defalult

@export var item_name :String = "DefalutName"
@export var item_image :Texture2D 
@export var item_scene :String
 
@export var item_weight :float =1 
@export var item_count : int = 1

@export var item_stakable : bool = false
@export var item_stack_amount :int = 1

#USE ONLY IF WEAPON!
@export_subgroup("Weapons States")
@export var weapon_hud :PackedScene 
@export var damage : float = 10
@export var shoot_in_secon: float = 10
@export var distance : float = 300
@export var horizontal_bullet_spread :  float = 0.01
@export var vertickal_bullet_spread :  float = 0.01
@export var scope_pos : Vector3 = Vector3(1.0,1.0,1.0)
@export_range(10,90,1) var scope_fov : float = 50
@export var reload_by_one : bool = false
@export var shoot_semi_auto : bool = false
@export var can_switch_shoot_type :bool = true
@export var has_hand_shoot : bool = false
@export var has_single_shoot :bool = true
@export var has_two_shoot :bool = false
@export var has_three_shoot :bool = false
@export var has_multi_shoot :bool = true
@export var recoil_power_horizontal :float = 5
@export var recoil_power_vertical : float = 10
@export_range(1,60,1) var scope_optika_fov : int = 20
@export var calibr : Global.WEAPON_CALIBR =  Global.WEAPON_CALIBR.w_762x39
@export var curent_calibr : Global.CALIBRS = Global.CALIBRS.b_762x39
@export var gp_calib : Global.WEAPON_CALIBR = Global.WEAPON_CALIBR.vog_25
@export var curent_gp_calibr : Global.CALIBRS = Global.CALIBRS.vog_25
@export var mamganzin_max :int =30
@export var magazine_curent : int =0
@export var gp_magazin_max : int = 1
@export var gp_magazin_curent : int = 1
@export var can_has_scope : bool =false
@export var can_has_gp : bool = false
@export var can_has_silenc : bool = false
@export var has_scope : bool =false
@export var has_gp : bool = false
@export var has_silenc : bool = false
@export var scope_scene : String 
@export var silenc_scene : String
@export var gp_scene : String 
#USE ONLY FOR AMMO
@export_subgroup("Ammo States")
@export var ammo_calibr : Global.CALIBRS = Global.CALIBRS.b_762x39
#USE ONLY FOR CONSUMERSITEMS
@export_subgroup("Consumer States")
@export var effect_hp_regen :int = 0
@export var effect_hp_time :int = 0
@export var effect_stamina_regen :int= 0
@export var effect_stamina_time :int= 0
@export var effect_blood_add : int = 0
@export var effect_blood_add_long : int = 0
@export var effect_blood_add_long_time : int = 0
@export var effect_antirad_add : int = 0
@export var effect_antirad_time : int 
@export_subgroup("Weapon Addon")
@export var weapon_assept_list :Array[String] 
@export var addon_type : Global.WEAPON_ADDON_TYPE 
