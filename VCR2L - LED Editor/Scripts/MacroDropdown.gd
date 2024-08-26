extends OptionButton

@onready var main_node = get_tree().root.get_node("Main")
@onready var current_macro_name = get_node("CurrentMacroName")
@onready var digits_node = main_node.get_node("Digits")


# Called when the node enters the scene tree for the first time.
func _ready():
	allow_reselect = true



func add_macros_from_dictionary(macros: Dictionary):
	var macros_size = macros.size()
	for n in macros:
		var macros_names = macros.keys()
		for x in item_count:
			if x == item_count:
				break
			if get_item_text(x) == n:
				remove_item(x)
		add_item(str(n))


func _on_item_selected(index):
	main_node.selected_macro  = get_item_text(index)
	current_macro_name.clear()
	current_macro_name.insert_text_at_caret(main_node.selected_macro)
	digits_node.set_all_digits_and_segments(main_node.current_macros[main_node.selected_macro])
