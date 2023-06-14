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
	var bittify_code_request = await NetworkRequests.login_with_bittify_code(bittify_code_textedit.text)
	if (!bittify_code_request.success):
		return
	var refresh_token = bittify_code_request.result.refresh_token
	var access_token = bittify_code_request.result.access_token
	ApplicationStorage.modify_data(ApplicationStorage.REFRESH_TOKEN, refresh_token)
	ApplicationStorage.modify_data(ApplicationStorage.ACCESS_TOKEN, access_token)

