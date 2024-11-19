extends RigidBody3D

class_name ItemScript

@export var item_conteiner :ItemContayner 

@export var _silenc : MeshInstance3D
@export var _gp :MeshInstance3D
@export var _scope :MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Weapon 1
	if item_conteiner.item_type == Global.ITEM_TYPE.weapon1 :
		if item_conteiner.can_has_gp :
			_gp.visible = item_conteiner.has_gp
		if item_conteiner.can_has_scope :
			_scope.visible = item_conteiner.has_scope
		if item_conteiner.can_has_silenc :
			_silenc.visible = item_conteiner.has_silenc
