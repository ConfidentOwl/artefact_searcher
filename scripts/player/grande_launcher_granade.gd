extends Node3D

class_name grande_launcher_granade

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D
@onready var sprite_3d: Sprite3D = $Sprite3D
@export var explo_time : float = 2

const DAMAGE :float = 50
const SPEEDFORWARD :float = 100
var _explo_beg : bool = true 
var _exp_time : float = explo_time

func _ready() -> void:
	self.top_level = true

func _physics_process(delta: float) -> void:
	if _explo_beg and ray_cast_3d.is_colliding():
		_explo_beg = false
		var res  =  shape_cast_3d.collision_result
		for i  in res :
			if i.collider.is_in_group("assert_damage") :
				i.collider.assert_damage(DAMAGE)
	elif  !_explo_beg :
		sprite_3d.show()
		sprite_3d.frame +=1
		_exp_time -= delta
		if _exp_time<0 :
			queue_free()
	else :
		translate(Vector3(0,0,delta * -SPEEDFORWARD))
