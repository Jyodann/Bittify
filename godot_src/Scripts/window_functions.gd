extends Node

const RESIZE_TIMEOUT = 0.5
const current_resize_timeout = 0
var current_timer = Timer.new()


func change_window_size(width, height, window = get_window()) -> void:
	window.size = Vector2i(width, height)


func change_window_position(x, y, window = get_window()) -> void:
	window.position = Vector2i(x, y)


func change_window_borderless(is_borderless, window = get_window()) -> void:
	if (OS.get_name() == "macOS"):
		window.extend_to_title = is_borderless
		return
	window.borderless = is_borderless


func change_window_always_on_top(is_always_on_top, window = get_window()) -> void:
	window.always_on_top = is_always_on_top


func set_up_min_window_size(window = get_window()) -> void:
	window.min_size = Vector2i(300, 250)


func minimize_window(window = get_window()) -> void:
	window.mode = Window.MODE_MINIMIZED


func focus_window(window = get_window()) -> void:
	window.mode = Window.MODE_WINDOWED

func window_resizable(resizable: bool, window = get_window()) -> void:
	window.unresizable = !resizable


func change_window_title(title, window = get_window()):
	if title == "":
		window.title = "Bittify"
		return
	window.title = "%s - Bittify" % title
