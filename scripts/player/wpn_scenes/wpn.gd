extends Node3D

class_name WpnScene

enum SHOOT_TYPE
{
	hand,
	single,
	two,
	three,
	multi
}

@export var _curent_shoot_state :SHOOT_TYPE = SHOOT_TYPE.single

@export_category("Weapons States")
var weapon_hud :WpnScene 
var damage : float 
var distance : float 
var scope_pos : Vector3 
var scope_fov : float 
var can_switch_shoot_type :bool 
var has_hand_shoot :bool
var has_single_shoot :bool 
var has_two_shoot :bool 
var has_three_shoot :bool 
var has_multi_shoot :bool 
var recoil_power_horizontal :float 
var recoil_power_vertical : float 
var mamganzin_max :int 

@export var animation_player: AnimationPlayer 
@export var bullet  := preload("res://scripts/player/bullet.tscn")
@export var fyze_sprite: FyzeSprite
@export var grande_launcher_grenade := preload("res://scripts/player/grande_launcher_granade.tscn") 

@export_category("Anim List")
@export var wpn_draw :String = "lancew_ak74_draw"
@export var wpn_holster :String = "lancew_ak74_holster"
@export var wpn_idle :String ="lancew_ak74_idle"
@export var wpn_scope :String ="lancew_ak74_idle_aim"
@export var wpn_reload :String = "lancew_ak74_reload"
@export var wpn_shoot :String = "lancew_ak74_shoot"
@export var wpn_sprint :String = "lancew_ak74_sprint"

@export var wpn_reload_one_begin: String  
@export var wpn_reload_one_add_one: String  
@export var wpn_reload_one_end: String  

@export var wpn_draw_gp :String = "lancew_ak74_draw_w_gl"
@export var wpn_holster_gp :String = "lancew_ak74_holster_w_gl"
@export var wpn_idle_gp :String ="lancew_ak74_idle_w_gl"
@export var wpn_scope_gp :String ="lancew_ak74_idle_aim_w_gl"
@export var wpn_reload_gp :String = "lancew_ak74_reload_w_gl"
@export var wpn_shoot_gp :String = "lancew_ak74_shoot_w_gl"
@export var wpn_launch_gp :String = "lancew_ak74_shoot_g"
@export var wpn_granade_reload :String = "lancew_ak74_reload_g"
@export var wpn_sprint_gp :String = "lancew_ak74_sprint_w_gl"

@export var wpn_knife_atack_1_begin :String = "kick1_start"
@export var wpn_knife_atack_1_end :String = "kick1_end"
@export var wpn_knife_atack_2_begin :String = "kick2_start"
@export var wpn_knife_atack_2_end :String = "kick2_end"
@export var wpn_knife_atack_new_begin :String = "new_kick_start"
@export var wpn_knife_atack_new_end :String = "new_kick_end"

@export_category("Weapon parts")
@export var silenc : String = "wpn_akm_hud_ogf/Skeleton3D/wpn_akm_hud_ogf 10"
@export var scope : String = "wpn_akm_hud_ogf/Skeleton3D/wpn_akm_hud_ogf 11"
@export var gp : String = "wpn_akm_hud_ogf/Skeleton3D/wpn_akm_hud_ogf 14"
@export var scope_texture : Texture2D 

var _wpn_draw : String
var _wpn_holster : String
var _wpn_idle : String
var _wpn_scope : String
var _wpn_reload : String 
var _wpn_shoot : String

var _my_fov :float = 75
var _player_link :Player
var _player_ammo_info_label : Label

var _has_silenc : bool  
var _has_scope :bool 
var _has_gp :bool  

var update_info :bool= true

var _in_animation :bool= false
var _wpn_in_hand :bool = false
var _gp_fire : bool = false

var _scope_need_call :bool = false
var _in_scope : bool = false
var _unscope_pos : Vector3 = Vector3.ZERO

var shoot_need :bool = false
var hand_atack_need : bool = false 

var _delta_shoot_in_seconds : float 
var _nex_shoot_delta : float 
var camera_3d: Camera3D 
var hand_controller: Node3D 

var _item_conteiner_link :ItemContayner
var _inventory_keeper : Inventroy_Keeper

var _shoot_pos :Node3D
var _optick_scrope : TextureRect
var _cross_scope :CenterContainer
var _recoil_node : PlayerRecoil

var _reload_by_one : bool 
var _curent_reload_by_one : bool 
var _shoot_semi_auto : bool
var _curent_state_reload_by_one : int = 0
#0 -not 1-begin 2-reloading 3 -end 

func _init() -> void:
	_player_link = Global.main_character
	_player_ammo_info_label = _player_link.CURENTAMMO
	_cross_scope = _player_link.RETICLE
	camera_3d = _player_link.PLAYER_CAMERA
	hand_controller = _player_link.HANDCONTROLLER
	_optick_scrope = _player_link.OPTICKSCOPETEXTURE
	_shoot_pos = _player_link.BUULETPOS
	_recoil_node = _player_link.RECOIL
	_unscope_pos = _player_link.HANDCONTROLLER.position

	update_info =true
func _process(delta: float) -> void:
	if hand_atack_need :
		hand_atack_1()
		hand_atack_need = false
	elif shoot_need :
		if !_gp_fire and _wpn_in_hand and animation_player and _item_conteiner_link.magazine_curent>0:
			if _curent_shoot_state == SHOOT_TYPE.single :
				shoot_single()
				shoot_need = false
			elif _curent_shoot_state == SHOOT_TYPE.multi :
				_nex_shoot_delta += delta
				if _delta_shoot_in_seconds < _nex_shoot_delta : 
					shoot_single()
					_nex_shoot_delta = 0
				else :
					fyze_sprite.end_fire()
		elif _gp_fire and _wpn_in_hand and animation_player and _item_conteiner_link.gp_magazin_curent>0:
			shoot_single()
			shoot_need = false
		else :
			fyze_sprite.end_fire()
	else :
		fyze_sprite.end_fire()

func _physics_process(_delta: float) -> void:
	if !animation_player.is_playing() and _wpn_in_hand :
		animation_player.play(_wpn_idle,-1,0.1,false)
	if update_info:
		damage = _item_conteiner_link.damage
		_delta_shoot_in_seconds = 1 / _item_conteiner_link.shoot_in_secon
		distance  =_item_conteiner_link.distance
		scope_pos  =_item_conteiner_link.scope_pos
		scope_fov  =_item_conteiner_link.scope_fov
		can_switch_shoot_type  =_item_conteiner_link.can_switch_shoot_type
		has_hand_shoot = _item_conteiner_link.has_hand_shoot
		has_single_shoot  =_item_conteiner_link.has_single_shoot
		has_two_shoot  =_item_conteiner_link.has_two_shoot
		has_three_shoot =_item_conteiner_link.has_three_shoot
		has_multi_shoot =_item_conteiner_link.has_multi_shoot
		recoil_power_horizontal =_item_conteiner_link.recoil_power_horizontal
		recoil_power_vertical =_item_conteiner_link.recoil_power_vertical
		mamganzin_max =_item_conteiner_link.mamganzin_max
		
		_inventory_keeper = _player_link.INVENTORYKEEPER
		
		_has_silenc = _item_conteiner_link.has_silenc
		_has_scope = _item_conteiner_link.has_scope
		_has_gp =_item_conteiner_link.has_gp
		
		_reload_by_one = _item_conteiner_link.reload_by_one
		_shoot_semi_auto = _item_conteiner_link.shoot_semi_auto
		
		change_has_gp()
		
		_recoil_node.update_recoilo_info(_item_conteiner_link.recoil_power_vertical,_item_conteiner_link.recoil_power_horizontal)
		
		update_info = false
		update_obves_info()
		set_blend_speeds()
		_player_ammo_info_label.text = get_curent_ammo_info()
	if _scope_need_call :
		scope_unscope(_in_scope)
		_scope_need_call = false
		_in_scope =!_in_scope
	if _curent_reload_by_one :
		match _curent_state_reload_by_one :
			0 :
				var amount : int  = _inventory_keeper.get_ammo_amount(self._item_conteiner_link.ammo_calibr)
				if amount > 0:
					_curent_reload_by_one = false
					return
				_curent_state_reload_by_one = 1
				animation_player.play(wpn_reload_one_begin)
				_in_animation = true 
			1 :
				if animation_player.current_animation == wpn_reload_one_begin :
					return
				else :
					_curent_state_reload_by_one = 2
			2:
				var amount : int = _inventory_keeper.get_ammo_amount(self._item_conteiner_link.curent_calibr)
				if animation_player.current_animation == wpn_reload_one_add_one:
					return
				if amount > 0 and _item_conteiner_link.magazine_curent < mamganzin_max  : 
					_item_conteiner_link.magazine_curent +=1
					_inventory_keeper.set_ammo_ammoount(self._item_conteiner_link.curent_calibr,amount-1)
					animation_player.play(wpn_reload_one_add_one)
					_in_animation = true 
				else :
					_curent_state_reload_by_one = 3
					animation_player.play(wpn_reload_one_end)
					_in_animation = true 
				_player_ammo_info_label.text = get_curent_ammo_info()
			3:
				if !_in_animation :
					_curent_state_reload_by_one =0
					_curent_reload_by_one = false

func shoot_single()->void:
	var anim_check : String = animation_player.current_animation 
	if anim_check.contains("draw") or anim_check.contains("holster") or anim_check.contains("reload"):
		return
	if _gp_fire :
		_item_conteiner_link.gp_magazin_curent -=1
		_player_ammo_info_label.text = get_curent_ammo_info()
		_recoil_node.add_recoil()
		animation_player.play(wpn_launch_gp)
		var granade = grande_launcher_grenade.instantiate()
		_shoot_pos.add_child(granade)
	else :
		if _item_conteiner_link.shoot_semi_auto :
			if animation_player.current_animation == _wpn_shoot :
				return 
			else:
				_item_conteiner_link.magazine_curent -=1
				_player_ammo_info_label.text = get_curent_ammo_info()
				if !_has_silenc : 
					fyze_sprite.need_fire()
				_recoil_node.add_recoil()
				animation_player.play(_wpn_shoot)
				var bullet_spawn = bullet.instantiate()
				_shoot_pos.add_child(bullet_spawn)
				bullet_spawn.random_offset_x = self._item_conteiner_link.horizontal_bullet_spread
				bullet_spawn.random_offset_y = self._item_conteiner_link.vertickal_bullet_spread
				bullet_spawn.run()
		else :
			_item_conteiner_link.magazine_curent -=1
			_player_ammo_info_label.text = get_curent_ammo_info()
			if !_has_silenc : 
				fyze_sprite.need_fire()
			_recoil_node.add_recoil()
			animation_player.play(_wpn_shoot,-1,10)
			var bullet_spawn = bullet.instantiate()
			_shoot_pos.add_child(bullet_spawn)
			bullet_spawn.random_offset_x = self._item_conteiner_link.horizontal_bullet_spread
			bullet_spawn.random_offset_y = self._item_conteiner_link.vertickal_bullet_spread
			bullet_spawn.run()

func wpn_comande_up() -> void:
	change_has_gp() 
	update_info = true
	if !_in_animation:
		_in_animation = true
		if !_wpn_in_hand : #UP
			_wpn_in_hand = true
			animation_player.play(_wpn_draw,-1,1,false)
		else : #DOWN
			_wpn_in_hand = false
			animation_player.play(_wpn_holster,-1,1,false)
	
func update_obves_info() ->void:
	if self._item_conteiner_link.can_has_silenc:
		get_node(silenc).visible = _has_silenc
	if self._item_conteiner_link.can_has_scope:
		get_node(scope).visible = _has_scope
	if self._item_conteiner_link.can_has_gp:
		get_node(gp).visible = _has_gp
	
func set_blend_speeds() ->void:
	animation_player.set_blend_time(wpn_reload,wpn_idle,0.5)
	animation_player.set_blend_time(wpn_idle,wpn_idle,0.5)

func scope_call() -> void:
	if _curent_shoot_state == SHOOT_TYPE.hand:
		hand_atack_2()
		return
	if !_in_animation and _wpn_in_hand:
		_scope_need_call = true
		return

func scope_unscope(scoping :bool) -> void:
	#Mechanik scop 
	if !_has_scope:
		if scoping :
			animation_player.play(_wpn_scope,-1,1,false)
			camera_3d.fov = _my_fov
			_cross_scope.show()
			hand_controller.position = _unscope_pos
		else :
			camera_3d.fov = scope_fov
			_cross_scope.hide()
			hand_controller.position = scope_pos
	else:
		if scoping :
			Global.main_character.PLAYER_CAMERA.fov = _my_fov
			Global.main_character.PLAYER_CAMERA.global_position = Global.main_character.CAMER_CONTROLLER.global_position
			_optick_scrope.hide()
			_cross_scope.show()
			self.show()
		else :
			Global.main_character.PLAYER_CAMERA.global_position = _shoot_pos.global_position
			Global.main_character.PLAYER_CAMERA.fov = _item_conteiner_link.scope_optika_fov
			_optick_scrope.texture = scope_texture 
			_optick_scrope.show()
			_cross_scope.hide()
			self.hide()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	_in_animation = false
	
func reload(add_ammo : int) -> int :
	if !_in_scope :
		if _in_animation or !_wpn_in_hand:
			_player_ammo_info_label.text =get_curent_ammo_info()
			return add_ammo
		if _gp_fire :
			_item_conteiner_link.gp_magazin_curent += add_ammo
			animation_player.play(wpn_granade_reload,-1,1,false)
		else  :
			## shootgane logick
			if _reload_by_one :
				_curent_reload_by_one = true 
				return add_ammo
			else :
				_item_conteiner_link.magazine_curent += add_ammo
				animation_player.play(_wpn_reload,-1,1,false)
		_in_animation= true
		var ret :int = 0
		if !_gp_fire and _item_conteiner_link.magazine_curent > mamganzin_max:
			ret = _item_conteiner_link.magazine_curent - mamganzin_max
			_item_conteiner_link.magazine_curent = mamganzin_max
		_player_ammo_info_label.text = get_curent_ammo_info()
		return ret
	return add_ammo
	
func switch_fire_type() -> void :
	_gp_fire =!_gp_fire
	_player_ammo_info_label.text = get_curent_ammo_info()
	
func change_has_gp() ->void :
	_has_gp =_item_conteiner_link.has_gp
	if _has_gp:
		_wpn_draw  = wpn_draw_gp
		_wpn_holster = wpn_holster_gp
		_wpn_idle = wpn_idle_gp
		_wpn_scope = wpn_scope_gp
		_wpn_reload  = wpn_reload_gp
		_wpn_shoot  = wpn_shoot_gp
	else :
		_wpn_draw  = wpn_draw
		_wpn_holster = wpn_holster
		_wpn_idle = wpn_idle
		_wpn_scope = wpn_scope
		_wpn_reload  = wpn_reload
		_wpn_shoot  = wpn_shoot
	
func get_curent_ammo_info() -> String :
	if !_gp_fire :
		return str(_item_conteiner_link.magazine_curent)
	else :
		return str(_item_conteiner_link.gp_magazin_curent)

func hand_atack_1() -> void:
	if animation_player.current_animation.contains("draw") :
		return
	if animation_player.current_animation.contains("holster") :
		return
	if animation_player.current_animation.contains("kick") :
		return
	animation_player.play(wpn_knife_atack_1_begin,-1,1,false)
	var knife_atack_speed : float = animation_player.current_animation_length
	await get_tree().create_timer(knife_atack_speed).timeout
	_player_link.cast_kife_cut(damage,distance)
	animation_player.play(wpn_knife_atack_1_end,-1,1,false)

func hand_atack_2() -> void:
	if animation_player.current_animation.contains("draw") :
		return
	if animation_player.current_animation.contains("holster") :
		return
	if animation_player.current_animation.contains("kick") :
		return
	animation_player.play(wpn_knife_atack_2_begin,-1,1,false)
	var knife_atack_speed : float = animation_player.current_animation_length
	await get_tree().create_timer(knife_atack_speed).timeout
	_player_link.cast_kife_cut(damage*2,distance* 0.5)
	animation_player.play(wpn_knife_atack_2_end,-1,1,false)

func shoot_need_set(_shoot_need : bool) -> void:
	if self._item_conteiner_link.shoot_semi_auto :
		#end load by 1 befo fool load 
		if _curent_state_reload_by_one != 0 :
			animation_player.play(wpn_reload_one_end)
			_in_animation = true 
			_curent_state_reload_by_one =3 
	if _curent_shoot_state != SHOOT_TYPE.hand:
		shoot_need = _shoot_need 
	else :
		hand_atack_need = _shoot_need 

func can_shou_hide_wpn() -> bool:
	var curent_anim :String = animation_player.current_animation
	if curent_anim.contains("holster") :
		return false
	if curent_anim.contains("draw") :
		return false
	if curent_anim.contains("kick") :
		return false
	if curent_anim.contains("reload") :
		return false
	return true

#TOOLS FOR DEVELOP !
func rotate_wpn(verikal : bool ,add : bool ) -> void :
	#if verikal:
		#if add: 
			#self.rotation.x = self.rotation.x +0.001
		#else :
			#self.rotation.x = self.rotation.x -0.001
	#else :
		#if add: 
			#self.rotation.y = self.rotation.y +0.001
		#else :
			#self.rotation.y = self.rotation.y -0.001
	print("rotation --")
	print(self.rotation)
	print("position --")
	print(self.position)
	
func move_wpn(verikal : bool ,add : bool ) -> void :
	if verikal:
		if add: 
			self.position.x = self.position.x +0.001
		else :
			self.position.x = self.position.x -0.001
	else :
		if add: 
			self.position.y = self.position.y +0.001
		else :
			self.position.y = self.position.y -0.001
	print("rotation --")
	print(self.rotation)
	print("position --")
	print(self.position)
