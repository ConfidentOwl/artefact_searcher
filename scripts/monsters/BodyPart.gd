extends StaticBody3D

class_name BodyPart

@export var ovner : CharacterBody3D 
@export var modifire_damage : float = 1

func assert_damage(damage: float ) ->void :
	print(damage)
	ovner.get_damage(modifire_damage*damage)

func get_ovner() -> CharacterBody3D:
	return ovner
