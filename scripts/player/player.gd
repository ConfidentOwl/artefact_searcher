extends CharacterBody3D

class_name Player

enum PLAYER_STATE
{
	idle,
	in_inventory,
	dead
}

@export_range(0,10,0.5) var CAMERA_SHAKE_POWER_BASE :float =0.25
@export var MAX_HP : float = 100
@export var MAX_DURATION :float = 100
@export var SPEED_DEFAULT : float = 5.0
@export var SPEED_CROUNCH :float = 2.0
@export var TOGGLE_CROUNCH : bool = true
@export var JUMP_VELOCITY :float  = 4.5
@export_range(5,10,0.1) var CROUNCH_SPEED :float = 7.0
@export var MOUSE_SENSETIVITY :=0.5
@export var TILT_LOWER_LIMIT :float = deg_to_rad(-80.0)
@export var TILT_UPPER_LIMIT :float= deg_to_rad(80.0)
@export var CAMER_CONTROLLER : Node3D
@export var ANIMATIONPLAYER : AnimationPlayer
@export var CROUNCH_SHAPECAST :ShapeCast3D
@export var PLAYER_CAMERA: Camera3D 
@export var INTERACTION : RayCast3D
@export var INVENTOYRUI :ItemInvetoryUIPlayer 
@export var CURENTCHESTUI : Item_Chest_List
@export var INVENTORYKEEPER : Inventroy_Keeper
@export var PLAYERSLOTS: PlayerSlots 
@export var RECOIL: PlayerRecoil 
@export var BUULETPOS: Node3D 
@export var OPTICKSCOPETEXTURE : TextureRect 
@export var HANDCONTROLLER :Node3D
@export var RETICLE : CenterContainer 
@export var PLAYERHP : ProgressBar
@export var PLAYERENDURANCE : ProgressBar
@export var CURENTAMMO : Label
@export var CURENTFIRERATE :Label 
@export var GAMEENDLABEL :Label 
@export var AMMOCONTAINERGUI : HBoxContainer 
@export var ITEMDROPER : Node3D 
@export var KNIFECAST : RayCast3D
@export var EFFECTUPDATE : EffectsUpdate
	
var _curent_HP :float = MAX_HP
var _curent_DURATION :float =MAX_DURATION
var _speed :float 
var _mouse_input : bool = false
var _mouse_rotation: Vector3
var _rotation_input : float 
var _tilt_input :float
var _player_rotation :Vector3
var _camera_rotation : Vector3
var _player_last_pos :Vector3
var _player_state : PLAYER_STATE = PLAYER_STATE.idle

var _curent_wpn_hud_scene : WpnScene = null 
var _wpn_config : bool = false

var _is_crounching :bool = false
var _in_gui:bool = false
#Camer shake move
var _curent_camera_step :int= 0
var _previ_camera_stp :int= 3
var _camer_shake_vieght :float= 0.0
var _speed_camera_lerp_modifire :float= 0.1
var _camera_shake_power_add :float= 1.0
var _camera_shake_steps :Array[Vector3] = [
	Vector3(0.1,-0.1,0),
	Vector3(0.1,0.1,0),
	Vector3(-0.1,-0.1,0),
	Vector3(-0.1,0.1,0)
]

func _update_camera(delta:float) -> void:
	_mouse_rotation.x += _tilt_input *delta*MOUSE_SENSETIVITY
	_mouse_rotation.x = clamp(_mouse_rotation.x,TILT_LOWER_LIMIT,TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta*MOUSE_SENSETIVITY
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)
	
	CAMER_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMER_CONTROLLER.rotation.z= 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func _ready() -> void:
	show_player_states_info()
	Global.main_character = self
	_speed = SPEED_DEFAULT
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CROUNCH_SHAPECAST.add_exception($".")
	AMMOCONTAINERGUI.hide()
	
func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _mouse_input :
		_rotation_input = -event.relative.x
		_tilt_input = -event.relative.y

func _physics_process(delta: float) -> void:
	_player_last_pos = self.position
	#Update HP info 
	PLAYERENDURANCE.value = _curent_DURATION
	PLAYERHP.value = _curent_HP
	if _curent_HP <= 0 :
		GAMEENDLABEL.show()
		_player_state = PLAYER_STATE.dead
	Global.debug_panel_player.draw_debug_line("FPS-",str(Engine.get_frames_per_second()))
	Global.debug_panel_player.draw_debug_line("POS-",str(self.position))
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	_update_camera(delta)
	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	var input_dir : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if _in_gui :
		input_dir = Vector2.ZERO
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)
		velocity.z = move_toward(velocity.z, 0, _speed)
	if _player_state != PLAYER_STATE.dead:
		if !_wpn_config :
			move_and_slide()
	if CAMERA_SHAKE_POWER_BASE > 0:
		camera_shake(delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"):
		get_tree().quit()
	if _player_state != PLAYER_STATE.dead:
		if _wpn_config:
			if event.is_action_pressed("ui_down"):
				_curent_wpn_hud_scene.rotate_wpn(true,false)
			if event.is_action_pressed("ui_up"):
				_curent_wpn_hud_scene.rotate_wpn(true,true)
			if event.is_action_pressed("ui_left"):
				_curent_wpn_hud_scene.rotate_wpn(false,false)
			if event.is_action_pressed("ui_right"):
				_curent_wpn_hud_scene.rotate_wpn(false,true)
			if event.is_action_pressed("move_backward"):
				_curent_wpn_hud_scene.move_wpn(true,false)
			if event.is_action_pressed("move_forward"):
				_curent_wpn_hud_scene.move_wpn(true,true)
			if event.is_action_pressed("move_left"):
				_curent_wpn_hud_scene.move_wpn(false,false)
			if event.is_action_pressed("move_right"):
				_curent_wpn_hud_scene.move_wpn(false,true)
		if event.is_action_pressed("Scope_Pos_And_Rotate_Turn_On"):
			_wpn_config =!_wpn_config
		if event.is_action_pressed("fire_type_switch") :
			if _curent_wpn_hud_scene != null and _curent_wpn_hud_scene._item_conteiner_link.has_gp :
				_curent_wpn_hud_scene.switch_fire_type()
				CURENTFIRERATE.text = get_fire_rate_info()
		if event.is_action_pressed("Crounch") and TOGGLE_CROUNCH:
			togle_crounch()
		if event.is_action("Crounch") and !TOGGLE_CROUNCH:
			togle_crounch()
		if event.is_action_pressed("Shoot") and !_in_gui and _curent_wpn_hud_scene != null:
			_curent_wpn_hud_scene.shoot_need_set(true)
		if event.is_action_released("Shoot") and _curent_wpn_hud_scene != null:
			_curent_wpn_hud_scene.shoot_need_set(false)
		if event.is_action_pressed("Scope") and !_in_gui and _curent_wpn_hud_scene != null:
			_curent_wpn_hud_scene.scope_call()## add weaposn swither
		if event.is_action_pressed("Reload")and !_in_gui and _curent_wpn_hud_scene != null:
			if !_curent_wpn_hud_scene._gp_fire :
				var needed_ammo : int = INVENTORYKEEPER.get_ammo_amount(_curent_wpn_hud_scene._item_conteiner_link.curent_calibr)
				if needed_ammo > 0 and _curent_wpn_hud_scene._item_conteiner_link.magazine_curent < _curent_wpn_hud_scene._item_conteiner_link.mamganzin_max :
					if _curent_wpn_hud_scene._item_conteiner_link.reload_by_one: 
						_curent_wpn_hud_scene.reload(needed_ammo)
					else :
						INVENTORYKEEPER.set_ammo_ammoount(_curent_wpn_hud_scene._item_conteiner_link.curent_calibr,_curent_wpn_hud_scene.reload(needed_ammo))
			else :
				var needed_ammo : int = INVENTORYKEEPER.get_ammo_amount(_curent_wpn_hud_scene._item_conteiner_link.curent_gp_calibr)
				if needed_ammo > 0 and _curent_wpn_hud_scene._item_conteiner_link.gp_magazin_curent < _curent_wpn_hud_scene._item_conteiner_link.gp_magazin_max :
					INVENTORYKEEPER.set_ammo_ammoount(_curent_wpn_hud_scene._item_conteiner_link.curent_gp_calibr,_curent_wpn_hud_scene.reload(needed_ammo))
			apdate_invemtory_list()
		if event.is_action_pressed("Switch_fire_rate") and _curent_wpn_hud_scene !=null:
			switch_fire_rate()
			CURENTFIRERATE.text = get_fire_rate_info()
		if event.is_action_pressed("Selet_Weapon_1")and !_in_gui :
			if _curent_wpn_hud_scene != null and !_curent_wpn_hud_scene.can_shou_hide_wpn():
				return
			if PLAYERSLOTS.weapon1_has :
				if _curent_wpn_hud_scene == null or !_curent_wpn_hud_scene._wpn_in_hand :
					wpn_1_up() 
				else :
					wpn_down()
					if _curent_wpn_hud_scene._item_conteiner_link.item_type != Global.ITEM_TYPE.weapon1:
						wpn_1_up()
		if event.is_action_pressed("Selet_Weapon_2") and !_in_gui:
			if _curent_wpn_hud_scene != null and !_curent_wpn_hud_scene.can_shou_hide_wpn():
				return
			if PLAYERSLOTS.weapon2_has :
				if _curent_wpn_hud_scene == null or !_curent_wpn_hud_scene._wpn_in_hand :
					wpn_2_up()
				else :
					wpn_down()
					if _curent_wpn_hud_scene._item_conteiner_link.item_type != Global.ITEM_TYPE.weapon2:
						wpn_2_up()
		if event.is_action_pressed("Select_Weapon3") and !_in_gui:
			if _curent_wpn_hud_scene != null and !_curent_wpn_hud_scene.can_shou_hide_wpn():
				return
			if PLAYERSLOTS.weapon3_has :
				if _curent_wpn_hud_scene == null or !_curent_wpn_hud_scene._wpn_in_hand :
					wpn_3_up()
				else :
					wpn_down()
					if _curent_wpn_hud_scene._item_conteiner_link.item_type != Global.ITEM_TYPE.weapon3:
						wpn_3_up()
		if event.is_action_pressed("Intercation")and !_in_gui :
			var res : Object = INTERACTION.get_collider()
			if res == null:
				return
			if res is ItemScript :
				INVENTORYKEEPER.add_item(res.item_conteiner.duplicate())
				res.queue_free()
			elif res is Inventory_Container :
				_player_state = PLAYER_STATE.in_inventory
				_in_gui = true
				CURENTCHESTUI.shou_gui(res.inventroy_keeper)
				if _curent_wpn_hud_scene != null and _curent_wpn_hud_scene._wpn_in_hand:
					_curent_wpn_hud_scene.wpn_comande_up()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				hide_player_states_info()
			if res is BodyPart:
				if res.get_owner().is_in_group("has_loot") :
					res.get_owner().get_loot(INVENTORYKEEPER)
		elif event.is_action_pressed("Intercation")and CURENTCHESTUI.visible:
			_player_state = PLAYER_STATE.idle
			_in_gui = false
			CURENTCHESTUI.hide_gui()
			INVENTOYRUI.hide_gui()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			show_player_states_info()
		if event.is_action_pressed("Inventory"):
			if _player_state != PLAYER_STATE.in_inventory:
				_player_state = PLAYER_STATE.in_inventory
			else :
				_player_state = PLAYER_STATE.idle
			if _player_state == PLAYER_STATE.in_inventory:
				_in_gui = true
				INVENTOYRUI.shou_gui()
				if _curent_wpn_hud_scene != null and _curent_wpn_hud_scene._wpn_in_hand:
					_curent_wpn_hud_scene.wpn_comande_up()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				hide_player_states_info()
			else :
				_in_gui = false
				INVENTOYRUI.hide_gui()
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				show_player_states_info()

func togle_crounch() ->void:
	if _is_crounching :
		try_uncrounch()
	elif !_is_crounching: # crounch
		ANIMATIONPLAYER.play("Crounch",0,CROUNCH_SPEED)
		_speed = SPEED_CROUNCH
		_is_crounching = true

func apdate_invemtory_list() ->void:
	INVENTOYRUI.update_item_list()

func try_uncrounch() -> void:
	if !CROUNCH_SHAPECAST.is_colliding():
		ANIMATIONPLAYER.play("Crounch",-1,-CROUNCH_SPEED,true)
		_is_crounching = false
		_speed = SPEED_DEFAULT
	elif !TOGGLE_CROUNCH :
		await get_tree().create_timer(0.1).timeout
		try_uncrounch()

func camera_shake(delta) -> void:
	if _player_last_pos == self.position:
		PLAYER_CAMERA.position = Vector3.ZERO
		_curent_camera_step = 0
		_previ_camera_stp = 3
		_camer_shake_vieght = 0
		return
	if _player_last_pos != self.position:
		_camer_shake_vieght+=delta
		var lerp_shake_prev = _camera_shake_steps[_previ_camera_stp]*CAMERA_SHAKE_POWER_BASE*_camera_shake_power_add
		var lerp_shake_next = _camera_shake_steps[_curent_camera_step]*CAMERA_SHAKE_POWER_BASE*_camera_shake_power_add
		PLAYER_CAMERA.position = lerp(lerp_shake_prev,lerp_shake_next,_camer_shake_vieght/(_speed_camera_lerp_modifire*_speed))
		if (_camer_shake_vieght/(_speed_camera_lerp_modifire*_speed)) > 1:
			_camer_shake_vieght =0
			if _curent_camera_step < 3:
				_curent_camera_step +=1
			else :
				_curent_camera_step =0
			if _previ_camera_stp < 3:
				_previ_camera_stp +=1
			else :
				_previ_camera_stp =0

func switch_fire_rate() -> void:
	var item_cont :ItemContayner = _curent_wpn_hud_scene._item_conteiner_link
	if item_cont.can_switch_shoot_type:
		var curent_fire_rate : WpnScene.SHOOT_TYPE = _curent_wpn_hud_scene._curent_shoot_state
		var new_fire_rate : WpnScene.SHOOT_TYPE  = curent_fire_rate
		while true :
			#hand 1
			if new_fire_rate == WpnScene.SHOOT_TYPE.hand :
				new_fire_rate = WpnScene.SHOOT_TYPE.single
				if item_cont.has_single_shoot :
					_curent_wpn_hud_scene._curent_shoot_state = new_fire_rate
					CURENTFIRERATE.text = get_fire_rate_info()
					return
			# 1  2
			if new_fire_rate == WpnScene.SHOOT_TYPE.single :
				new_fire_rate = WpnScene.SHOOT_TYPE.two
				if item_cont.has_two_shoot :
					_curent_wpn_hud_scene._curent_shoot_state = new_fire_rate
					CURENTFIRERATE.text = get_fire_rate_info()
					return
			# 2  3
			if new_fire_rate == WpnScene.SHOOT_TYPE.two :
				new_fire_rate = WpnScene.SHOOT_TYPE.three
				if item_cont.has_three_shoot :
					_curent_wpn_hud_scene._curent_shoot_state = new_fire_rate
					CURENTFIRERATE.text = get_fire_rate_info()
					return
			# 3 multi 
			if new_fire_rate == WpnScene.SHOOT_TYPE.three :
				new_fire_rate = WpnScene.SHOOT_TYPE.multi
				if item_cont.has_multi_shoot :
					_curent_wpn_hud_scene._curent_shoot_state = new_fire_rate
					CURENTFIRERATE.text = get_fire_rate_info()
					return
			# multi  1
			if new_fire_rate == WpnScene.SHOOT_TYPE.multi :
				new_fire_rate = WpnScene.SHOOT_TYPE.hand
				if item_cont.has_hand_shoot :
					_curent_wpn_hud_scene._curent_shoot_state = new_fire_rate
					CURENTFIRERATE.text = get_fire_rate_info()
					return

func get_fire_rate_info()-> String:
	var curent_fire_rate : WpnScene.SHOOT_TYPE = _curent_wpn_hud_scene._curent_shoot_state
	if ! _curent_wpn_hud_scene._gp_fire :
		match  curent_fire_rate:
			WpnScene.SHOOT_TYPE.hand:
				return "knife"
			WpnScene.SHOOT_TYPE.single:
				return "ONE"
			WpnScene.SHOOT_TYPE.two:
				return "TWO"
			WpnScene.SHOOT_TYPE.two:
				return "THREE"
			WpnScene.SHOOT_TYPE.multi:
				return "MULTI"
			_:
				return "Erore -get unsuported shoot type"
	else :
		return "GRENADE"
		
func clear_weapon_gui_info() -> void:
	CURENTAMMO.text = " "
	CURENTFIRERATE.text = " "

func hide_player_states_info() -> void:
	PLAYERHP.hide()
	PLAYERENDURANCE.hide()
	CURENTAMMO.hide()
	CURENTFIRERATE.hide()

func show_player_states_info() -> void:
	PLAYERHP.show()
	PLAYERENDURANCE.show()
	CURENTAMMO.show()
	CURENTFIRERATE.show()

func get_damage(damage :float) -> void:
	_curent_HP-=damage

func get_blooding(count :float) -> void:
	EFFECTUPDATE.add_blooding(count)

func get_radion(count :float) -> void:
	EFFECTUPDATE.add_radion(count)

func check_weapon_in_hand() -> bool:
	if _curent_wpn_hud_scene == null:
		return false
	return _curent_wpn_hud_scene._wpn_in_hand 

func wpn_1_up() -> void:
	if _curent_wpn_hud_scene!= null :
		self.wpn_down()
		_curent_wpn_hud_scene.queue_free()
	AMMOCONTAINERGUI.show()
	var new_weapon :WpnScene= PLAYERSLOTS.weapon1.weapon_hud.instantiate()
	HANDCONTROLLER.add_child(new_weapon)
	new_weapon._item_conteiner_link = PLAYERSLOTS.weapon1
	_curent_wpn_hud_scene =new_weapon
	_curent_wpn_hud_scene.wpn_comande_up()
	CURENTFIRERATE.text = get_fire_rate_info()

func wpn_2_up() -> void:
	if _curent_wpn_hud_scene!= null :
		self.wpn_down()
		_curent_wpn_hud_scene.queue_free()
	AMMOCONTAINERGUI.show()
	var new_weapon :WpnScene= PLAYERSLOTS.weapon2.weapon_hud.instantiate()
	HANDCONTROLLER.add_child(new_weapon)
	new_weapon._item_conteiner_link = PLAYERSLOTS.weapon2
	_curent_wpn_hud_scene =new_weapon
	_curent_wpn_hud_scene.wpn_comande_up()
	CURENTFIRERATE.text = get_fire_rate_info()
	
func wpn_3_up() -> void:
	if _curent_wpn_hud_scene!= null :
		self.wpn_down()
		_curent_wpn_hud_scene.queue_free()
	AMMOCONTAINERGUI.show()
	var new_weapon :WpnScene= PLAYERSLOTS.weapon3.weapon_hud.instantiate()
	HANDCONTROLLER.add_child(new_weapon)
	new_weapon._item_conteiner_link = PLAYERSLOTS.weapon3
	_curent_wpn_hud_scene =new_weapon
	_curent_wpn_hud_scene.wpn_comande_up()
	CURENTFIRERATE.text = get_fire_rate_info()

func wpn_down() -> void:
	if _curent_wpn_hud_scene != null and  _curent_wpn_hud_scene._in_scope:
		_curent_wpn_hud_scene.scope_unscope(true)
		_curent_wpn_hud_scene._scope_need_call = false
	AMMOCONTAINERGUI.hide()
	clear_weapon_gui_info()
	if _curent_wpn_hud_scene != null :
		_curent_wpn_hud_scene.wpn_comande_up()

func cast_kife_cut(damage: float , distance:float) -> void:
	KNIFECAST.target_position.z = -distance
	var res : Object = KNIFECAST.get_collider()
	if res is BodyPart:
		res.assert_damage(damage)
