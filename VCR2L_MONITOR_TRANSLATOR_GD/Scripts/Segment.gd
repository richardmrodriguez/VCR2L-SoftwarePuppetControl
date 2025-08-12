extends Sprite2D

@export var segment_number = 0

@export var segment_on = true


# Called when the node enters the scene tree for the first time.

func _on_mouse_clicked():
	segment_on = !segment_on
	print("Segment " + str(segment_number) + ":" + str(segment_on))
	
func _ready():
	var area_2d_node = get_node("Area2D")
	area_2d_node.area_2d_mouse_clicked.connect(_on_mouse_clicked)
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if segment_on == true:
		modulate = Color(1, 1, 1)
	else:
		modulate = Color(1, 1, 1, .05)


#func _on_area_2d_input_event(viewport, event, shape_idx):
#
#	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
#		if get_viewport_rect().has_point(to_local(event.position)):
#			print("This segment clicked: " + str(segment_number)) 
