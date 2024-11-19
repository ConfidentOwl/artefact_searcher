extends Area3D

class_name Radion_Around
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@export var hard : float = 5

func _physics_process(delta: float) -> void:
	var size : float =  self.global_transform.basis.x.length()
	var res : Array[Node3D] = self.get_overlapping_bodies()
	for i : Node3D in res :
		if i is Player :
			var distace : float = i.position.distance_to(self.position)
			if distace > size :
				continue 
			else :
				i.get_radion(hard*(distace/size))
