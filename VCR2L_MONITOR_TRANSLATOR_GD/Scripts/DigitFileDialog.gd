extends FileDialog

@onready var digits = get_tree().root.get_node("Main/Digits")

var window_size = {
	"w": 960,
	"h": 400
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func open_save_menu(menu_text: String):
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	popup_centered(Vector2i(window_size["w"], window_size["h"]))
	set_title(menu_text)
	
func open_load_menu(menu_text: String):
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	popup_centered(Vector2i(window_size["w"], window_size["h"]))
	set_title(menu_text)
	

func is_digit_in_file(file):
	pass

func add_digit_to_file(file):
	pass
	
func overwrite_digit_in_file(file):
	pass
	

func _on_file_selected(path):
	pass # Replace with function body.



