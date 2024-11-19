extends Area3D

class_name Coling_Help

func call_around(pos : Vector3) -> void:
	var res : Array[Node3D] = self.get_overlapping_bodies()
	for i in res :
		if i.is_in_group("zombi") :
			var i_z : Zombi = i as Zombi  
			i_z.get_coling(pos)
