extends Area2D

signal area_2d_mouse_clicked
@export var test_var = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		area_2d_mouse_clicked.emit()
