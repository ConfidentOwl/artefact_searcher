extends Node3D

class_name FyzeSprite


@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var animated_sprite_3d_2: AnimatedSprite3D = $AnimatedSprite3D2
@onready var animated_sprite_3d_3: AnimatedSprite3D = $AnimatedSprite3D3
@onready var animated_sprite_3d_4: AnimatedSprite3D = $AnimatedSprite3D4
@onready var animated_sprite_3d_5: AnimatedSprite3D = $AnimatedSprite3D5
@onready var animated_sprite_3d_6: AnimatedSprite3D = $AnimatedSprite3D6
@onready var animated_sprite_3d_7: AnimatedSprite3D = $AnimatedSprite3D7
@onready var animated_sprite_3d_8: AnimatedSprite3D = $AnimatedSprite3D8

var _need_fire :bool = false
var _fire :bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	if _need_fire:
		if !_fire :
			_fire = true
			shou_sprite()
	if !_need_fire:
		if _fire:
			_fire = false
			hide_sprite()

func shou_sprite() -> void :
	animated_sprite_3d.show()
	animated_sprite_3d_2.show()
	animated_sprite_3d_3.show()
	animated_sprite_3d_4.show()
	animated_sprite_3d_5.show()
	animated_sprite_3d_6.show()
	animated_sprite_3d_7.show()
	animated_sprite_3d_8.show()
	
func hide_sprite() -> void:
	animated_sprite_3d.hide()
	animated_sprite_3d_2.hide()
	animated_sprite_3d_3.hide()
	animated_sprite_3d_4.hide()
	animated_sprite_3d_5.hide()
	animated_sprite_3d_6.hide()
	animated_sprite_3d_7.hide()
	animated_sprite_3d_8.hide()

func need_fire() -> void:
	_need_fire = true

func end_fire() -> void:
	_need_fire = false
