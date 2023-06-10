extends Control

var following = false
var dragging_start_pos = Vector2i.ZERO

func _gui_input(event):
	if (following && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		var mouse_position = get_global_mouse_position() as Vector2i
		var vector = DisplayServer.window_get_position() + mouse_position - dragging_start_pos

		print(vector)

		DisplayServer.window_set_position(
			vector
		)

	if !(event is InputEventMouseButton):
		return
	var button = event as InputEventMouseButton
	if (button.button_index == MOUSE_BUTTON_LEFT):
		following = button.pressed
		dragging_start_pos = get_global_mouse_position() as Vector2i
