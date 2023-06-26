extends Node

const RESIZE_TIMEOUT = 0.5
const current_resize_timeout = 0
var current_timer = Timer.new()

func change_window_size(width, height, window = get_window()) -> void:

	window.size = Vector2i(width, height)
	
func change_window_borderless(is_borderless, window = get_window()) -> void:
	window.borderless = is_borderless

func change_window_always_on_top(is_always_on_top, window = get_window()) -> void:
	window.always_on_top = is_always_on_top
	
func set_up_min_window_size(window = get_window()) -> void:
	window.min_size = Vector2i(300, 250)

func change_window_title(title, window = get_window()):
	if (title == ""):
		window.title = "Bittify"
		return
	window.title = "%s - Bittify" % title


func set_up_resize():
	current_timer = Timer.new()
	add_child(current_timer)
	current_timer.autostart = true
	current_timer.one_shot = true
	get_tree().root.size_changed.connect(
		on_resize_prepared
	)
	current_timer.start(RESIZE_TIMEOUT)
	current_timer.timeout.connect(
		func():
			var size = DisplayServer.window_get_size()
			ApplicationStorage.modify_data(ApplicationStorage.Settings.WIN_HEIGHT, size.y)
			ApplicationStorage.modify_data(ApplicationStorage.Settings.WIN_WIDTH, size.x)
	)

func on_resize_prepared():
	
	if (current_timer.wait_time > 0):
		current_timer.stop()
	current_timer.start(RESIZE_TIMEOUT)
	
