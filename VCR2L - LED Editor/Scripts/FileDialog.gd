extends FileDialog

@onready var main_node = get_tree().root.get_node("Main")
@onready var digits = main_node.get_node("Digits")
@onready var macro_dropdown = get_parent().get_node("MacroDropdown")

var window_size = {
	"w": 960,
	"h": 400
}

enum save_types {
	ADD_NEW_MACRO,
	OVERWRITE_MACRO,
}


func _on_save_macro_shape_pressed():
	open_save_menu("Save Macro Shape As: ")


func _on_load_macro_shape_pressed():
	open_load_menu("Load macro: ")
	
func open_save_menu(menu_text: String):
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	popup_centered(Vector2i(window_size["w"], window_size["h"]))
	set_title(menu_text)
	
func open_load_menu(menu_text: String):
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	popup_centered(Vector2i(window_size["w"], window_size["h"]))
	set_title(menu_text)


func _on_file_selected(path):
	var json = JSON.new()
	
	match file_mode:
		FILE_MODE_OPEN_FILE: 	# JSON writes the integers as "strings", 
								# which means the indexes have to be read with str()
			var file
			
			if FileAccess.file_exists(path):
				file = FileAccess.open(path, FileAccess.READ)
			else:
				print("File not found: " + str(path))
				file.close()
				return
			
			var opened_macros = JSON.parse_string(file.get_as_text())
			
			print("Opening file: " + str(path))
			#print(str(opened_macros))
			main_node.current_macros = opened_macros
			macro_dropdown.clear()
			macro_dropdown.add_macros_from_dictionary(opened_macros)
			
			file.close()
		
		FILE_MODE_SAVE_FILE:
			
			var file
			var macros_to_save = main_node.current_macros
			
			file = FileAccess.open(path, FileAccess.WRITE)
			var string = JSON.stringify(macros_to_save)
			
			file.store_line(string)
			
			print("Saving to file: " + str(path))
			file.close()

		_:
			print("Invalid File Mode.")
		
	
func is_macro_in_file(macro_name: String, file_as_dict):
	if macro_name in file_as_dict:
		pass
	
func add__new_macro_to_file(file):
	pass

func overwrite_macro_in_file(file):
	pass
	



