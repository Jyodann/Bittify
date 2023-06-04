extends Node

func change_window_size(width, height):
	get_window().size = Vector2i(width, height)
	
func change_window_borderless(is_borderless):
	get_window().borderless = is_borderless

func change_window_always_on_top(is_always_on_top):
	get_window().always_on_top = is_always_on_top
	
