extends OptionButton

@onready var main_node = get_node("../..")

func _ready() -> void:
	item_selected.connect(_on_port_selected)

signal port_selected(port_name: String)

func _on_port_selected(id: int):
	var item_name = get_item_text(id)
	port_selected.emit(item_name)
	
