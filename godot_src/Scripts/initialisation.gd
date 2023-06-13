extends Control

func _ready():
	print("Performing Initial Startup checks")
	
	var win_height = ApplicationStorage.get_data(ApplicationStorage.WIN_HEIGHT)
	var win_width = ApplicationStorage.get_data(ApplicationStorage.WIN_WIDTH)

	WindowFunctions.change_window_size(win_width, win_height)
