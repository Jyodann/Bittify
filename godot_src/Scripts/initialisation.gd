extends Control
@onready var player_page = preload("res://Pages/player_page.tscn")
@onready var content_holder = $ContentPage
func _ready():
	print("Performing Initial Startup checks")
	
	var win_height = ApplicationStorage.get_data(ApplicationStorage.WIN_HEIGHT)
	var win_width = ApplicationStorage.get_data(ApplicationStorage.WIN_WIDTH)
	WindowFunctions.set_up_min_window_size()
	WindowFunctions.change_window_size(win_width, win_height)

	
	ContentPageShell.set_content_page_holder(content_holder)
	
	var access_token = ApplicationStorage.get_data(ApplicationStorage.ACCESS_TOKEN)

	var res = await NetworkRequests.currently_playing_song(access_token)
	print(res.result)
	if (!res.success):
		
		ContentPageShell.load_view(ContentPageShell.Page.LOGIN_PAGE)
	else:
		ContentPageShell.load_view(ContentPageShell.Page.PLAYER_PAGE)



