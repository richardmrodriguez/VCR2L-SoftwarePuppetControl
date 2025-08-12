extends Node2D

@onready var display_1: Node = %Digits
@onready var display_2: Node = %Digits2
@onready var file_dialog = get_node("Main Controls/FileDialog")
@onready var digit_file_dialog = get_node("Main Controls/DigitFileDialog")
@onready var gdserial_obj: Object = GdSerial.new()

var current_open_port_name: String
@export var port_open: bool = false

var selected_midi_input_channel: int = 0

var segments_dict_clipboard = {}
var current_macros = {
}
var selected_macro = "Empty2"

func _ready() -> void:
	%SerialPortDropdown.port_selected.connect(_on_serial_port_selected)
	
	print_debug(gdserial_obj)
	
	var ports_dict = gdserial_obj.list_ports()
	
	for port_num in ports_dict:
		var port_listed_as_dict = ports_dict[port_num]
		var port_name: String = port_listed_as_dict["port_name"]
		if port_name.contains("USB") or port_name.contains("COM"):
			%SerialPortDropdown.add_item(port_name) 
			print(port_num, "|", port_listed_as_dict)	
		pass		
	print_debug("Opening MIDI Inputs...")
	OS.open_midi_inputs()
	if not OS.get_connected_midi_inputs().is_empty():
		%Channels.add_theme_color_override("font_color", Color.GREEN)
		
	file_dialog.open_load_menu("Open Macro from file: ")

	
	
func _process(delta: float) -> void:
	if port_open:
		var available_bytes: int = gdserial_obj.bytes_available()
		if available_bytes > 0:
			print("SERIAL: |",gdserial_obj.read_string(available_bytes))

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
				segments_dict_clipboard = display_1.get_child(0).get_segments()
			if Input.is_key_pressed(KEY_2):
				segments_dict_clipboard = display_1.get_child(1).get_segments()
			if Input.is_key_pressed(KEY_3):
				segments_dict_clipboard = display_1.get_child(2).get_segments()
			if Input.is_key_pressed(KEY_4):
				segments_dict_clipboard = display_1.get_child(3).get_segments()
				
		elif alt:
			print("alt")
		elif shift:
			
			print("shift")
			# -------- Paste Digit Segments to Digit of Choice --------------------
			
			if Input.is_key_pressed(KEY_1):
				display_1.get_child(0).set_segments(segments_dict_clipboard)
			if Input.is_key_pressed(KEY_2):
				display_1.get_child(1).set_segments(segments_dict_clipboard)
			if Input.is_key_pressed(KEY_3):
				display_1.get_child(2).set_segments(segments_dict_clipboard)
			if Input.is_key_pressed(KEY_4):
				display_1.get_child(3).set_segments(segments_dict_clipboard)
		else:
			
			# -------- Invert Keys ------------------------------------------------
			
			if Input.is_key_pressed(KEY_Q):
				display_1.get_child(0)._on_invert_segments()
			if Input.is_key_pressed(KEY_W):
				display_1.get_child(1)._on_invert_segments()
			if Input.is_key_pressed(KEY_E):
				display_1.get_child(2)._on_invert_segments()
			if Input.is_key_pressed(KEY_R):
				display_1.get_child(3)._on_invert_segments()
				
			# -------- Flip Horizontal Keys ---------------------------------------
				
			if Input.is_key_pressed(KEY_A):
				display_1.get_child(0)._on_flip_horizontal_pressed()
			if Input.is_key_pressed(KEY_S):
				display_1.get_child(1)._on_flip_horizontal_pressed()
			if Input.is_key_pressed(KEY_D):
				display_1.get_child(2)._on_flip_horizontal_pressed()
			if Input.is_key_pressed(KEY_F):
				display_1.get_child(3)._on_flip_horizontal_pressed()
				
			# -------- Flip Vertical Keys------------------------------------------
			
			if Input.is_key_pressed(KEY_Z):
				display_1.get_child(0)._on_flip_vertical_pressed()
			if Input.is_key_pressed(KEY_X):
				display_1.get_child(1)._on_flip_vertical_pressed()
			if Input.is_key_pressed(KEY_C):
				display_1.get_child(2)._on_flip_vertical_pressed()
			if Input.is_key_pressed(KEY_V):
				display_1.get_child(3)._on_flip_vertical_pressed()
			
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

# ----- Serial ----------------------------------------------------- 

func _on_serial_port_selected(port_name: String):
	print("on_serial_port_called")
	var current_ports = gdserial_obj.list_ports()
	for port_num in current_ports:
		var port_listed_as_dict: Dictionary = current_ports[port_num]
		if port_listed_as_dict["port_name"] == port_name:
			if gdserial_obj.is_open():
				gdserial_obj.close()
			print("Setting the port to: ", port_name)
			gdserial_obj.set_port(port_name)
			gdserial_obj.set_baud_rate(115200)
			if gdserial_obj.open():
				port_open = true
				%SerialPortLabel.add_theme_color_override("font_color", Color.GREEN)
				return
			else:
				print_debug("Failed to open serial port!")
				%SerialPortLabel.add_theme_color_override("font_color", Color.RED)
				return
		
	%SerialPortLabel.add_theme_color_override("font_color", Color.RED)
		

func _get_14_bit_binary_digit_from_macro_digit(macro_digit: Dictionary) -> int:
	#print_debug("GETTING 14 BIT DIGIT...")
	var binary_digit = 0b0
	for segment in macro_digit:
		var seg_value: bool = macro_digit[segment]
		#print_debug("SEG VALUE:", seg_value)
		if seg_value:
			var seg_as_int = int(segment)
			#print_debug("SEG AS INT: ", seg_as_int)
			binary_digit = binary_digit | (0b1 << seg_as_int)
	
	binary_digit = binary_digit & 0b0011_1111_1111_1111
	return binary_digit
	

func _get_macro_expression_as_binary_digits(macro_expression: Dictionary) -> PackedByteArray:
	var macro_as_14_bit_digits: Array[int] = []
	var macro_as_packed_byte_array: PackedByteArray = []
	for digit: Variant in macro_expression:
		var digit_segments = macro_expression[digit]
		macro_as_14_bit_digits.append(_get_14_bit_binary_digit_from_macro_digit(digit_segments))
	for digit: int in macro_as_14_bit_digits:
		var lo = int(digit) & 0xFF
		var hi = (int(digit) >> 8) & 0xFF
		macro_as_packed_byte_array.append(lo)
		macro_as_packed_byte_array.append(hi)
	return macro_as_packed_byte_array
	
func _get_serial_message_from_MIDI(midi_event: InputEventMIDI, macro_expression: Dictionary) -> PackedByteArray:
	
	var macro_byte_array: PackedByteArray = _get_macro_expression_as_binary_digits(macro_expression).duplicate()
	macro_byte_array.append(midi_event.velocity & 0xFF)
	macro_byte_array.append(midi_event.channel & 0xFF)
	return macro_byte_array


# ----- MIDI ---------------------------------

func _input(event):
	if event is InputEventMIDI:
		if event.channel > 1:
			return
		if event.message != MIDI_MESSAGE_NOTE_ON:
			return
		print("Midi note received! | ", event.pitch)
		print("Midi velocity: ", event.velocity)

		if not event.pitch < current_macros.keys().size():
			print_debug("Can't find macro for that pitch: ", event.pitch)
			print(current_macros.keys())
			return
		if current_macros.keys().is_empty():
			print_debug("No macros loaded...")
			return
		var macro_dict: Dictionary = current_macros[current_macros.keys()[event.pitch]]
		if macro_dict.is_empty():
			print_debug("Couldn't find macro for midi note: ", event.pitch)
			return
		#
		var real_brightness: int = roundi(
			(remap(
				clamp(event.velocity, 0, 80), 
				0, 
				80, 
				0, 
				15)))
		var preview_brightness: float = remap(real_brightness, 0, 15, 63, 255)
		var mod_color: Color = Color8(255, 255, 255, preview_brightness)
		if event.channel == 0:
			display_1.set_all_digits_and_segments(macro_dict)
			display_1.modulate = mod_color
			# TODO: Also set the brightness
			# TODO: Also create and send the serial message
		if event.channel == 1:
			display_2.set_all_digits_and_segments(macro_dict)
			display_2.modulate = mod_color
		
		if port_open:
			#print_debug("sending message to ESP32...")
			var serial_status_bytes: PackedByteArray = [0b0001_0000]
			var message: PackedByteArray = _get_serial_message_from_MIDI(event, macro_dict)
			#print_debug("MESSAGE: ", message)
			gdserial_obj.write(serial_status_bytes)
			gdserial_obj.write(message)
		
