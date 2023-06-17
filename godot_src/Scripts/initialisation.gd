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
	
	attempt_load_player_page()

	
func attempt_load_player_page():
	var access_token = ApplicationStorage.get_data(ApplicationStorage.ACCESS_TOKEN)
	var res = await NetworkRequests.currently_playing_song(access_token)
	var refresh_token = ApplicationStorage.get_data(ApplicationStorage.REFRESH_TOKEN)
	if (!res.success):
		if (res.result.response_code == 401):
			var new_token = await NetworkRequests.get_new_access_token(refresh_token)

			if (new_token.success):
				ApplicationStorage.modify_data(ApplicationStorage.ACCESS_TOKEN, new_token.result.body_string.access_token)
				attempt_load_player_page()
				return
		ContentPageShell.load_view(ContentPageShell.Page.LOGIN_PAGE)
	else:
		ContentPageShell.load_view(ContentPageShell.Page.PLAYER_PAGE)


