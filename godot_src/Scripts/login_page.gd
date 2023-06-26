extends Control


@onready var login_button = $VBoxContainer/LoginToSpotifyButton
@onready var bittify_code_go_button = $VBoxContainer/HBoxContainer/BittifyCodeGoButton
@onready var bittify_code_textedit = $VBoxContainer/HBoxContainer/BittifyCodeTextEdit

func _ready():
	login_button.pressed.connect(self._login_button_pressed)
	bittify_code_go_button.pressed.connect(self._bittify_go_button_pressed)
	
func _login_button_pressed():
	OS.shell_open(NetworkRequests.oauth_url)

func _bittify_go_button_pressed():
	bittify_code_go_button.disabled = true
	var bittify_code_request = await NetworkRequests.login_with_bittify_code(bittify_code_textedit.text)
	bittify_code_go_button.disabled = false
	if (!bittify_code_request.success):
		return
	print(bittify_code_request.result.body_string)
	var refresh_token = bittify_code_request.result.body_string.refresh_token
	var access_token = bittify_code_request.result.body_string.access_token
	ApplicationStorage.modify_data(ApplicationStorage.Settings.REFRESH_TOKEN, refresh_token)
	ApplicationStorage.modify_data(ApplicationStorage.Settings.ACCESS_TOKEN, access_token)

	ContentPageShell.load_view(ContentPageShell.Page.SETTINGS_PAGE)


