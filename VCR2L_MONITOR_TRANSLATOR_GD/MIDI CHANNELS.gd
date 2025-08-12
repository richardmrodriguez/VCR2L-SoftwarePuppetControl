extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	for n: int in range(16):
		add_item(str(n))
	item_selected.connect(func(index: int) -> void:
		var main: Node = get_tree().root.get_child(0)
		main.selected_midi_input_channel = index
		print("updated MIDI input channel: ", main.selected_midi_input_channel)
		)
