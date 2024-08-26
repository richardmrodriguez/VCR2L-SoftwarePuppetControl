extends Node2D
@export var digit = 0


@onready var segments = get_node("Segments")
@onready var number_of_segments = segments.get_child_count()


# -------------- Buttons ----------------------------------------

func _on_invert_segments():
	for s in number_of_segments:
		var seg = segments.get_child(s)
		seg.segment_on = !seg.segment_on
	print("Inverted segments.")

func _on_flip_horizontal_pressed():
	var seg_dict = get_segments()
	var horizontal_flip_table = {
		0:0,
		3:3,
		8:8,
		12:12,
		
		1:5,
		5:1,
		2:4,
		4:2,
		6:10,
		10:6,
		7:9,
		9:7,
		11:13,
		13:11
		
	}
	
	var h_flipped_segs = {}
	
	for n in seg_dict:
		var h_flip_seg_key = horizontal_flip_table[n]
		h_flipped_segs[h_flip_seg_key] = seg_dict[n]
	
	set_segments(h_flipped_segs)
	
func _on_flip_vertical_pressed():
	var seg_dict = get_segments()
	var vertical_flip_table = {
		0:3,
		3:0,
		1:2,
		2:1,
		4:5,
		5:4,
		
		6:6,
		10:10,
		
		7:13,
		13:7,
		8:12,
		12:8,
		9:11,
		11:9,
		
	}
	
	var v_flipped_segs = {}
	
	for n in seg_dict:
		var v_flip_seg_key = vertical_flip_table[n]
		v_flipped_segs[v_flip_seg_key] = seg_dict[n]
	
	set_segments(v_flipped_segs)
	
func _on_load_digit_pressed():
	pass
	
func _on_save_digit_pressed():
	pass

# -------------- Getters and Setters ---------------------------
	
func get_segments():
	var segments_dict = {}
	
	for s in number_of_segments:
		segments_dict[s] = segments.get_child(s).segment_on
		
	return segments_dict
	
func set_segments(new_segs: Dictionary):
	
	if new_segs != {}:
		for s in new_segs:
			segments.get_child(int(s)).segment_on = new_segs[s]
			
	
