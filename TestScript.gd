extends Node2D


func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_event : InputEventMouseButton = event
		if mouse_event.button_index == 1:
			print("Left Click!")
		elif mouse_event.button_index == 2:
			print("Right Click!")
	elif event is InputEventKey:
		var key_event :InputEventKey = event
		if key_event.keycode == KEY_SPACE:
			if key_event.pressed:
				print("Spacebar!")
			else:
				print("Spacebar Released!")
