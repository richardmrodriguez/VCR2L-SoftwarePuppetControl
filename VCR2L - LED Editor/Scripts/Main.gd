extends Node2D

@onready var digits = get_node("Digits")
@onready var file_dialog = get_node("Main Controls/FileDialog")
@onready var digit_file_dialog = get_node("Main Controls/DigitFileDialog")

var segments_dict_clipboard = {}
var current_macros = {
}
var selected_macro = "Empty2"


func _unhandled_key_input(event):
	# get modifier key statuses as variables
	if event is InputEventKey and event.pressed:
		var ctrl = Input.is_key_pressed(KEY_CTRL)
		var alt = Input.is_key_pressed(KEY_ALT)
		var shift = Input.is_key_pressed(KEY_SHIFT)
	
		if ctrl and alt and shift:
			print("ctrl alt shift")
		elif ctrl and alt:
			print("ctrl alt")
		elif ctrl and shift:
			print("ctrl shift")
		elif alt and shift:
			print("alt shift")
		elif ctrl:
			print("ctrl")
			
			# -------- Copy Digit Segments to Clipboard -----------------
			
			if Input.is_key_pressed(KEY_1):
				segments_dict_clipboard = digits.get_child(0).get_segments()
			if Input.is_key_pressed(KEY_2):
				segments_dict_clipboard = digits.get_child(1).get_segments()
			if Input.is_key_pressed(KEY_3):
				segments_dict_clipboard = digits.get_child(2).get_segments()
			if Input.is_key_pressed(KEY_4):
				segments_dict_clipboard = digits.get_child(3).get_segments()
				
		elif alt:
			print("alt")
		elif shift:
			
			print("shift")
			# -------- Paste Digit Segments to Digit of Choice --------------------
			
			if Input.is_key_pressed(KEY_1):
				digits.get_child(0).set_segments(segments_dict_clipboard)
			if Input.is_key_pressed(KEY_2):
				digits.get_child(1).set_segments(segments_dict_clipboard)
			if Input.is_key_pressed(KEY_3):
				digits.get_child(2).set_segments(segments_dict_clipboard)
			if Input.is_key_pressed(KEY_4):
				digits.get_child(3).set_segments(segments_dict_clipboard)
		else:
			
			# -------- Invert Keys ------------------------------------------------
			
			if Input.is_key_pressed(KEY_Q):
				digits.get_child(0)._on_invert_segments()
			if Input.is_key_pressed(KEY_W):
				digits.get_child(1)._on_invert_segments()
			if Input.is_key_pressed(KEY_E):
				digits.get_child(2)._on_invert_segments()
			if Input.is_key_pressed(KEY_R):
				digits.get_child(3)._on_invert_segments()
				
			# -------- Flip Horizontal Keys ---------------------------------------
				
			if Input.is_key_pressed(KEY_A):
				digits.get_child(0)._on_flip_horizontal_pressed()
			if Input.is_key_pressed(KEY_S):
				digits.get_child(1)._on_flip_horizontal_pressed()
			if Input.is_key_pressed(KEY_D):
				digits.get_child(2)._on_flip_horizontal_pressed()
			if Input.is_key_pressed(KEY_F):
				digits.get_child(3)._on_flip_horizontal_pressed()
				
			# -------- Flip Vertical Keys------------------------------------------
			
			if Input.is_key_pressed(KEY_Z):
				digits.get_child(0)._on_flip_vertical_pressed()
			if Input.is_key_pressed(KEY_X):
				digits.get_child(1)._on_flip_vertical_pressed()
			if Input.is_key_pressed(KEY_C):
				digits.get_child(2)._on_flip_vertical_pressed()
			if Input.is_key_pressed(KEY_V):
				digits.get_child(3)._on_flip_vertical_pressed()
			
			# -------- Load and Save Keys -----------------------------------------
			
			if Input.is_key_pressed(KEY_F1):
				file_dialog.open_load_menu("Open Macro from file: ")
			
#				digit_file_dialog.open_load_menu("Open digit from file: ")
				
				
			elif Input.is_key_pressed(KEY_F5):
				file_dialog.open_save_menu("Save Macro to: ")
#			elif Input.is_key_pressed(KEY_F6):
#				digit_file_dialog.open_load_menu("Save Digit to: ")
				
			# -------- Miscellaneous Functions ------------------------------------

			if Input.is_key_pressed(KEY_F2):
				print("List of Macro Names: ")
				var macro_names = current_macros.keys()
				var num = 0
				for n in macro_names:
					print(str(num) + ": '" + n + "',")
					num += 1
