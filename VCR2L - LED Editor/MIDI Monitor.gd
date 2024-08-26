extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_button_clicked)


func _on_button_clicked() -> void:
	OS.open_midi_inputs()
	var midi_inputs: Array = OS.get_connected_midi_inputs()
	if midi_inputs.is_empty():
		print("No Midi inputs available.")
		return

	print("Midi ports: ")
	for port in midi_inputs:
		print(port)
