extends CharacterBody3D

class_name Zombi

enum zombi_states 
{
	idle,
	idle_seet,
	walk,
	eat,
	run,
	atack,
	last_see_enemy,
	look_enemy_around,
	psevdo_die,
	dead
}

var curent_state :zombi_states = zombi_states.idle
@onready var skeleton_3d: Skeleton3D = $zombi_1/zombi_1_ogf/Skeleton3D

@onready var coling_help: Coling_Help = $Coling_Help
@export var animation_player: AnimationPlayer 

@export var navigation_agent_3d :NavigationAgent3D
@export var MOVESPEED : float = 0.75
@export var RUN_SPEED : float = 3.0
@export var RANDOM_END_MOVING_IDLE : int = 30
@export var RANDOM_BEGIN_MOVING_IDLE : int = 10
@export var LOOK_FOR_ENEMY_SECOND : int = 20
@export var ATACK_RANGE : float = 1.5
@export var ATACK_DAMAGE : float = 10
@export var HP:float = 1000

var _curent_hp : float = HP
var _damage_cool_down : float = 0
var rng = RandomNumberGenerator.new()

var enemy_around : bool = false
var look_enemy_around : bool = false
var get_new_random_point : bool = false
var try_get_rnadom_new_point_delay_max : float = 1
var try_get_rnadom_new_point_delay : float = try_get_rnadom_new_point_delay_max
var look_for_enemy_timer : float = LOOK_FOR_ENEMY_SECOND
var targets : Array[Node3D]
var last_pos_enemy : Vector3
var random_next_pos : Vector3
var need_new_random_point :bool 
var look_for_enemy_amount : int = 0

var _previev_idle_animation :String ="stand_idle_0"

@onready var inventroy_keeper: Inventroy_Keeper = $Inventroy_Keeper
@export var awalade_loot_list : Array[String]
@export var chanse_loot_spawn : Array[int]

func _init() -> void:
	randomize()

func _physics_process(delta: float) -> void:
	# Cheker states 
	if _damage_cool_down >-1:
		_damage_cool_down -=delta
	if _curent_hp <=0 :
		curent_state = zombi_states.dead
		set_physics_process(false)
	elif targets.size() >0 : # see enemy 
		if get_new_random_point :
			update_terget_location(targets[0].position)
		get_new_random_point = false
		curent_state = zombi_states.run
		enemy_around = true
		if position.distance_to(targets[0].position) <= ATACK_RANGE :
			curent_state = zombi_states.atack
	elif enemy_around :# look enemy 
		curent_state = zombi_states.last_see_enemy
	elif get_new_random_point :
		curent_state = zombi_states.walk
	else :# idle 
		if !get_new_random_point :
			curent_state = zombi_states.idle
			try_get_rnadom_new_point_delay -= delta
			randomize()
			if  randf_range(0,1) > 0.5 and try_get_rnadom_new_point_delay <=0 :
				var can : bool = get_random_move_new_point()
				if can :
					curent_state = zombi_states.walk
					try_get_rnadom_new_point_delay = try_get_rnadom_new_point_delay_max
			#else :
				#try_get_rnadom_new_point_delay = try_get_rnadom_new_point_delay_max
	##STATE mahine begin
	match curent_state :
		zombi_states.idle :
			if animation_player.is_playing():
				return
			if  _previev_idle_animation == "" :
				randomize()
				match randi_range(0, 7):
					0:
						animation_player.play("stand_idle_0")
						_previev_idle_animation = "stand_idle_0"
					1: 
						animation_player.play("stand_idle_0_")
						_previev_idle_animation = "stand_idle_0_"
					2:
						animation_player.play("stand_idle_1_001")
						_previev_idle_animation = "stand_idle_1_001"
					3:
						animation_player.play("stand_idle_2")
						_previev_idle_animation = "stand_idle_2"
					4:
						animation_player.play("stand_idle_2")
						_previev_idle_animation = "stand_idle_2"
					5:
						animation_player.play("stand_idle_3")
						_previev_idle_animation = "stand_idle_3"
					6:
						animation_player.play("stand_idle_4")
						_previev_idle_animation = "stand_idle_4"
					7:
						animation_player.play("stand_idle_6")
						_previev_idle_animation = "stand_idle_6"
					_:
						printerr("Get int niot indefine in animtion selector - zombi_states.idle ")
			else :
				animation_player.play(_previev_idle_animation,-1,-1,true)
				_previev_idle_animation = ""
		zombi_states.walk:
			random_walk_animtion()
			var curent_pos = global_transform.origin
			var next_location = navigation_agent_3d.get_next_path_position()
			var new_velocity = (next_location - curent_pos).normalized() * MOVESPEED
			navigation_agent_3d.velocity_computed.emit(new_velocity)
			look_at(next_location)
			if navigation_agent_3d.is_target_reached():
				get_new_random_point = false
		zombi_states.run:
			random_run_animation()
			update_terget_location(targets[0].position)
			var curent_pos = global_transform.origin
			last_pos_enemy = navigation_agent_3d.get_next_path_position()
			var next_location = navigation_agent_3d.get_next_path_position()
			var new_velocity = (next_location - curent_pos).normalized() * RUN_SPEED
			navigation_agent_3d.velocity_computed.emit(new_velocity)
			look_at(next_location)
		zombi_states.atack:
			random_atack_animation()
			if _damage_cool_down <=0 :
				_damage_cool_down = animation_player.get_animation("stand_attack_0").length
				var target :Node3D= targets[0]
				if target is Player :
					target.get_damage(ATACK_DAMAGE)
					target.get_blooding(ATACK_DAMAGE/10 )
		zombi_states.last_see_enemy:
			random_run_animation()
			update_terget_location(last_pos_enemy)
			var curent_pos = global_transform.origin
			var next_location = navigation_agent_3d.get_next_path_position()
			var new_velocity = (next_location - curent_pos).normalized() * RUN_SPEED
			navigation_agent_3d.velocity_computed.emit(new_velocity)
			look_at(next_location)
		zombi_states.dead:
			randomize()
			create_loot()
			match randi_range(0, 3):
				0:
					animation_player.play("fake_death_1_0",0,1,false)
				1:
					animation_player.play("fake_death_2_0",0,1,false)
				2:
					animation_player.play("fake_death_3_0",0,1,false)
				3:
					animation_player.play("fake_death_4_0",0,1,false)
		_: 
			printerr("Get erore -undefine state !!")

func update_terget_location(target_location : Vector3) -> void:
	navigation_agent_3d.set_target_position(target_location)

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity,25)
	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("stalker"):
		targets.append(body)
		coling_help.call_around(body.position)

func _on_area_3d_body_exited(body: Node3D) -> void:
	targets.erase(body)

func get_damage(damage :float ) -> void:
	_curent_hp -=damage

func get_random_point_around() -> Vector3:
	var rand_offset : int = 20
	
	var x : float = randf_range(-rand_offset, rand_offset)
	var y : float = randf_range(-rand_offset, rand_offset)
	var z : float = randf_range(-rand_offset, rand_offset)
	
	var my_pos : Vector3 = self.global_position
	
	return Vector3(my_pos.x+x,my_pos.y+y,my_pos.z+z)

func get_random_move_new_point() -> bool:
	var new_rand_point : Vector3 = get_random_point_around()
	navigation_agent_3d.set_target_position(new_rand_point)
	if navigation_agent_3d.is_target_reachable() :
		var new_point : Vector3 = navigation_agent_3d.get_next_path_position()
		if self.position.distance_to(new_point) > 5 :
			get_new_random_point = true
			return true 
	return false 

func get_coling(pos : Vector3) -> void:
	curent_state = zombi_states.walk
	navigation_agent_3d.set_target_position(pos)
	get_new_random_point = true

func random_walk_animtion() -> void:
	if animation_player.current_animation.contains("stand_walk_fwd") :
		return
	randomize()
	match randi_range(0, 5):
		0:
			animation_player.play("stand_walk_fwd_0",0,1,false)
		1:
			animation_player.play("stand_walk_fwd_1",0,1,false)
		2:
			animation_player.play("stand_walk_fwd_2",0,1,false)
		3:
			animation_player.play("stand_walk_fwd_3",0,1,false)
		4:
			animation_player.play("stand_walk_fwd_4",0,1,false)
		5:
			animation_player.play("stand_walk_fwd_5",0,1,false)

func random_run_animation() -> void:
	if animation_player.current_animation.contains("stand_run") :
		return
	randomize()
	match randi_range(0, 14):
		0:
			animation_player.play("stand_run_1",0,1,false)
		1:
			animation_player.play("stand_run_2",0,1,false)
		2:
			animation_player.play("stand_run_3",0,1,false)
		3:
			animation_player.play("stand_run_4",0,1,false)
		4:
			animation_player.play("stand_run_5",0,1,false)
		5:
			animation_player.play("stand_run_6",0,1,false)
		6:
			animation_player.play("stand_run_7",0,1,false)
		7:
			animation_player.play("stand_run_8",0,1,false)
		8:
			animation_player.play("stand_run_9",0,1,false)
		9:
			animation_player.play("stand_run_10",0,1,false)
		10:
			animation_player.play("stand_run_11",0,1,false)
		11:
			animation_player.play("stand_run_12",0,1,false)
		12:
			animation_player.play("stand_run_13",0,1,false)
		13:
			animation_player.play("stand_run_14",0,1,false)

func random_atack_animation() -> void :
	if animation_player.current_animation.contains("stand_attack_") :
		return
	randomize()
	match randi_range(0, 3):
		0:
			animation_player.play("stand_attack_0",0,1,false)
		1:
			animation_player.play("stand_attack_1",0,1,false)
		2:
			animation_player.play("stand_attack_2",0,1,false)
		3:
			animation_player.play("stand_attack_3",0,1,false)

func create_loot() -> void:
	for i in range(awalade_loot_list.size()):
		randomize()
		if chanse_loot_spawn[i] == 0 :
			continue
		if (randi() % 100 + 1) > chanse_loot_spawn[i] :
			inventroy_keeper.add_item(load(awalade_loot_list[i]).instantiate().item_conteiner)

func get_loot(inventorykeepr_target : Inventroy_Keeper) -> void:
	for i: ItemContayner in inventroy_keeper.MainList:
		inventorykeepr_target.add_item(i)
	inventroy_keeper.MainList.clear()
	self.remove_from_group("has_loot")
