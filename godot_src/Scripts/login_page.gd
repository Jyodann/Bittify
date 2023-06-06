extends Node2D


@onready var login_button = $Control/VBoxContainer/LoginToSpotifyButton
@onready var bittify_code_go_button = $Control/VBoxContainer/HBoxContainer/BittifyCodeGoButton
@onready var bittify_code_textedit = $Control/VBoxContainer/HBoxContainer/BittifyCodeTextEdit

func _ready():
	login_button.pressed.connect(self._login_button_pressed)
	bittify_code_go_button.pressed.connect(self._bittify_go_button_pressed)
	
func _login_button_pressed():
	OS.shell_open(NetworkRequests.oauth_url)

func _bittify_go_button_pressed():
	var bittify_code_request = await NetworkRequests.login_with_bittify_code(bittify_code_textedit.text)
	if (!bittify_code_request.success):
		return
		
	var access_token_request = await NetworkRequests.get_new_access_token(bittify_code_request.result.refresh_token)

	if (!access_token_request.success):
		return
	
	print("Login Success: %s" % access_token_request.result.access_token)

