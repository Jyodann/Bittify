extends Node

const RESIZE_TIMEOUT = 0.5
const current_resize_timeout = 0
var current_timer = Timer.new()

func change_window_size(width, height):
	get_window().size = Vector2i(width, height)
	
func change_window_borderless(is_borderless):
	get_window().borderless = is_borderless

func change_window_always_on_top(is_always_on_top):
	get_window().always_on_top = is_always_on_top
	
func set_up_min_window_size():
	get_window().min_size = Vector2i(300, 250)

func change_window_title(title):
	if (title == ""):
		DisplayServer.window_set_title("Bittify")
		return
	DisplayServer.window_set_title("%s - Bittify" % title)


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
			ApplicationStorage.modify_data(ApplicationStorage.WIN_HEIGHT, size.y)
			ApplicationStorage.modify_data(ApplicationStorage.WIN_WIDTH, size.x)
	)

func on_resize_prepared():
	
	if (current_timer.wait_time > 0):
		current_timer.stop()
	current_timer.start(RESIZE_TIMEOUT)
	
