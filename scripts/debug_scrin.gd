extends Panel

class_name DebugPanelPlayer

@onready var property_contayner: VBoxContainer = $MarginContainer/VBoxContainer
@onready var player: Player = $"../.."
var property_list : Array[Label] 
var fps :String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.debug_panel_player = self
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("DebugPanelSwitch"):
		visible = !visible

func draw_debug_line(title : String , value : String) -> void:
	for i in property_list.size():
		var key :Label = property_list[i]
		if key.name == title:
			key.text = key.name +" :"+value
			return
	var property_c : Label = Label.new()
	property_list.append(property_c)
	property_contayner.add_child(property_c)
	property_c.name = title
	property_c.text = property_c.name +":"+value
