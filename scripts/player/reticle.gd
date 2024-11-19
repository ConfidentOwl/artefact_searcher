extends CenterContainer
@export var RETICLE_LINES :Array[Line2D]
@export var PlAYER_CONTROLLER :Player
@export var RECTANGLE_SPEED : float = 0.25
@export var RETICLE_DISTANCE : float = 2.0
@export var DOT_RADIUS : float = 1.0
@export var DOT_COLOR : Color = Color.WHITE_SMOKE
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	adjust_recticle_lines()
func _draw() -> void:
	draw_circle(Vector2.ZERO,DOT_RADIUS,DOT_COLOR)
	
func adjust_recticle_lines():
	var vel = PlAYER_CONTROLLER.get_real_velocity()
	var origin =Vector3.ZERO
	var pos =Vector2.ZERO
	var speed = origin.distance_to(vel)
	
	RETICLE_LINES[0].position = lerp(RETICLE_LINES[0].position, pos + Vector2(0,-speed * RETICLE_DISTANCE), RECTANGLE_SPEED)
	RETICLE_LINES[1].position = lerp(RETICLE_LINES[1].position, pos + Vector2(speed * RETICLE_DISTANCE,0), RECTANGLE_SPEED)
	RETICLE_LINES[2].position = lerp(RETICLE_LINES[2].position, pos + Vector2(0,speed * RETICLE_DISTANCE), RECTANGLE_SPEED)
	RETICLE_LINES[3].position = lerp(RETICLE_LINES[3].position, pos + Vector2(-speed * RETICLE_DISTANCE,0), RECTANGLE_SPEED)
