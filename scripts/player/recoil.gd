extends Node3D

class_name PlayerRecoil

@export var recoil_amount:Vector3
@export var snap_amount :float 
@export var speed : float

var current_rotation :Vector3
var target_rotation :Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	target_rotation = lerp(target_rotation,Vector3.ZERO,speed *delta)
	current_rotation = lerp(current_rotation,target_rotation,snap_amount *delta)
	basis = Quaternion.from_euler(current_rotation)
	
func add_recoil() -> void:
	target_rotation +=Vector3(randf_range(0,recoil_amount.x)
	,randf_range(-recoil_amount.y,recoil_amount.y)
	,randf_range(-recoil_amount.z,recoil_amount.z))
	

func update_recoilo_info(vertical :float , horizontal:float) -> void:
	recoil_amount.x = vertical
	recoil_amount.y = horizontal
