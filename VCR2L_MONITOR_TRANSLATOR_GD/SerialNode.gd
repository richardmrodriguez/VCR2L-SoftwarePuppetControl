extends Node

@onready var serial: Object = GdSerial.new()

func _ready() -> void:
	print("Serial...")
	#print(serial)

func get_serial() -> Object:
	if serial:
		return serial
	return null
