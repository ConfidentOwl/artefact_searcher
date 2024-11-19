extends Node3D

@onready var timer: Timer = $Timer

const BULLET := preload("res://scripts/player/bullet.tscn")
var speed : float = 500
var random_offset_x : float = 0
var random_offset_y : float = 0
var bullet_amount : int = 8

func _init() -> void:
	pass
		
func run() -> void :
	for i in range(bullet_amount):
		
		randomize()
		var x : float = randf_range(-random_offset_x, random_offset_x)
		var y : float = randf_range(-random_offset_y, random_offset_y)
				
		var bullet : Bullet= BULLET.instantiate()
		bullet.DAMAGE/=(bullet_amount/4)
		#bullet.SPEEDFORWARD = speed
		self.add_child(bullet)
		bullet.rotation.x+=x
		bullet.rotation.y+=y
		
func _on_timer_timeout() -> void:
	queue_free() # Replace with function body.
