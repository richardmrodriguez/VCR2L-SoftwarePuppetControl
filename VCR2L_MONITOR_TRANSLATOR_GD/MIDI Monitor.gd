extends Button

var inputs_opened: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_button_clicked)
	var temp_inputs: PackedStringArray = OS.get_connected_midi_inputs()
	print_debug("Getting MIDI INPUTS...")
	print_debug(temp_inputs)

func _on_button_clicked() -> void:
	var channels: Label = get_node("%Channels")
	if channels:
		#print_debug("Channels label exists!")
		pass
		
	var midi_inputs: Array = OS.get_connected_midi_inputs()
	if midi_inputs.is_empty():
		print("No Midi inputs available.")
		channels.add_theme_color_override("font_color", Color.RED)
		return
	channels.add_theme_color_override("font_color", Color.GREEN)
	print("Midi ports: ")
	for port in midi_inputs:
		print(port)
