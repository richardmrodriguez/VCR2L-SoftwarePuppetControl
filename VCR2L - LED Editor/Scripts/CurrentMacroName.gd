extends LineEdit

func _input(event):
	if event is InputEventKey and event.pressed:
		if Input.is_key_pressed(KEY_ESCAPE):
			release_focus()
