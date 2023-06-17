extends Node

func change_window_size(width, height):
	get_window().size = Vector2i(width, height)
	
func change_window_borderless(is_borderless):
	get_window().borderless = is_borderless

func change_window_always_on_top(is_always_on_top):
	get_window().always_on_top = is_always_on_top
	
func set_up_min_window_size():
	get_window().min_size = Vector2i(200, 250)

func change_window_title(title):
	if (title == ""):
		DisplayServer.window_set_title("Bittify")
		return
	DisplayServer.window_set_title("%s - Bittify" % title)
	