extends Node2D

	
func get_all_digits_and_segments():
	var num_digits = get_child_count()
	var digits_segments_dict = {}
	
	for n in num_digits:
		digits_segments_dict[n] = get_child(n).get_segments()
		
	return digits_segments_dict
	
func set_all_digits_and_segments(dict: Dictionary):
	var num_digits = get_child_count()
	
	if dict.has(0):
	
		for n in num_digits:
			get_child(n).set_segments(dict[n])
			
	elif dict.has("0"):
		for n in num_digits:
			#print(str(get_child(n)))
			get_child(n).set_segments(dict[str(n)])
	
	else:
		print("Unrecognized dictionary.")
