extends Control
@onready var content_holder = $ContentPage


func _ready():
	ContentPageShell.set_content_page_holder(content_holder)
	attempt_load_player_page()


func attempt_load_player_page():
	var access_token = ApplicationStorage.get_data(ApplicationStorage.Settings.ACCESS_TOKEN)
	var res = await NetworkRequests.currently_playing_song(access_token)
	var refresh_token = ApplicationStorage.get_data(ApplicationStorage.Settings.REFRESH_TOKEN)
	if !res.success:
		if res.result.response_code == 401:
			var new_token = await NetworkRequests.get_new_access_token(refresh_token)

			if new_token.success:
				ApplicationStorage.modify_data(
					ApplicationStorage.Settings.ACCESS_TOKEN,
					new_token.result.body_string.access_token
				)
				attempt_load_player_page()
				return

		if res.result.response_code == 204:
			ContentPageShell.load_view(ContentPageShell.Page.PLAYER_PAGE)
			return

		ContentPageShell.load_view(ContentPageShell.Page.LOGIN_PAGE)
	else:
		ContentPageShell.load_view(ContentPageShell.Page.PLAYER_PAGE)
