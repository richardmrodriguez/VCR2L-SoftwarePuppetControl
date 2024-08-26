extends Control

@onready var main_node = get_tree().root.get_node("Main")
@onready var digits_node = get_node("/root/Main/Digits")
@onready var macro_control_node = get_node("MacroDropdown")

func _ready():
	pass

	
func _on_print_all_segments_pressed():
	print(str(digits_node.get_all_digits_and_segments()))
	


func _on_add_new_macro_pressed():
	var cur_macros = main_node.current_macros
	var cur_macro_name = main_node.selected_macro
	
	var new_macro_name = macro_control_node.get_node("CurrentMacroName").text
	print("new macro name: " + str(new_macro_name))
	var new_macro = digits_node.get_all_digits_and_segments()
	var new_dict = {
		new_macro_name: new_macro
	}
	
	macro_control_node.add_macros_from_dictionary(new_dict)
	main_node.current_macros[new_macro_name] = new_macro
	main_node.selected_macro = new_macro_name


func _on_delete_current_macro_pressed():
	var cur_macro_name = main_node.selected_macro
	for x in macro_control_node.item_count:
			if macro_control_node.get_item_text(x) == cur_macro_name:
				macro_control_node.remove_item(x) 
	
	if cur_macro_name in main_node.current_macros:
		main_node.current_macros.erase(cur_macro_name)
