extends Node3D

class_name Bullet
var shoot:bool = false
@onready var METAL_DECAL := preload("res://scripts/decals/bullets/metal_decal.tscn")

@onready var blood_partickle: GPUParticles3D = $Blood_Partickle
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var DAMAGE :float = 50
var SPEEDFORWARD :float = 100
var _colide : bool = false
var random_offset_x : float = 0
var random_offset_y : float = 0

func _ready() -> void:
	self.top_level = true

func run() -> void:
	pass

func _physics_process(delta: float) -> void:
	if random_offset_x != 0 or random_offset_y != 0:
		
		randomize()
		var x : float = randf_range(-random_offset_x, random_offset_x)
		var y : float = randf_range(-random_offset_y, random_offset_y)
		
		self.rotation.y += x
		self.rotation.x += y
		random_offset_x = 0
		random_offset_y = 0
	if ray_cast_3d.is_colliding():
		var object :Object = ray_cast_3d.get_collider()
		if !_colide and  object.is_in_group("assert_damage"):
			object.assert_damage(DAMAGE)
			blood_partickle.emitting = true
			_colide = true
			blood_partickle.global_position = ray_cast_3d.get_collision_point()
		await get_tree().create_timer(0.15).timeout
		queue_free()
	else :
		translate(Vector3(0,0,delta * -SPEEDFORWARD))
