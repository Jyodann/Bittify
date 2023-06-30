extends Node

var http_request_nodes = {}
const CLIENT_ID = "9830ce611cad40ab98aaca36e75c0b79"

@onready var base_url = "http://127.0.0.1:8787" if OS.has_feature("debug") else "https://bittifybackend.jyodann.workers.dev"

@onready var redirect_url = "%s/callback" % base_url
@onready var get_token_url = "%s/get_access_token" % base_url

@onready var get_refresh_token_url = "%s/get_refresh_token" % base_url

@onready var oauth_url = "https://accounts.spotify.com/authorize?client_id=%s&response_type=code&redirect_uri=%s&scope=user-modify-playback-state user-read-currently-playing" % [CLIENT_ID, redirect_url]

var currently_online = true

class Result:
	var success: bool
	var result: Dictionary

	func _init(_success, _result):
		self.success = _success
		self.result = _result

func create_new_http_request_node(request_node_name: String) -> HTTPRequest:
	if (http_request_nodes.has(request_node_name)):
		return http_request_nodes[request_node_name]
	
	var request = HTTPRequest.new()

	request.timeout = 5

	http_request_nodes[request_node_name] = request
	add_child(http_request_nodes[request_node_name])
	return http_request_nodes[request_node_name]

func login_with_bittify_code(bittify_code: String) -> Result:
	var client = create_new_http_request_node("bittify_login_code")
	var url = "%s?code=%s&redirect_url=%s" % [get_token_url, bittify_code, redirect_url]
	
	if (client == null):
		return Result.new(
			false, {}
		)

	client.request(url)

	var res = await client.request_completed
	
	return check_for_sucess(res, false)
		
#"https://api.spotify.com/v1/me/player/currently-playing?additional_types=episode,track"
func currently_playing_song(access_token: String) -> Result:
	var client = create_new_http_request_node("currently_playing_song")
	var url = "https://api.spotify.com/v1/me/player/currently-playing?additional_types=episode,track"

	client.request( url, [
		"Authorization: Bearer %s" % access_token,
		"Content-Type: application/json"
	], HTTPClient.METHOD_GET)

	var res = await client.request_completed

	return check_for_sucess(res, false)
		
func get_new_access_token(refresh_token) -> Result:
	var client = create_new_http_request_node("new_access_token")
	var url = "%s?refresh_token=%s" % [get_refresh_token_url, refresh_token]

	client.request(
		url
	);

	var res = await client.request_completed
	return check_for_sucess(res, false)

func download_album_art(link) -> Result:
	var client = create_new_http_request_node("download_album")
	
	client.request(
		link
	);

	var res = await client.request_completed
	
	return check_for_sucess(res, true)

func check_for_sucess(res, return_raw: bool) -> Result:
	var result = res[0] as HTTPRequest.Result
	var response_code = res[1] as int
	# Godot Errors:
	
	if (result == HTTPRequest.Result.RESULT_CANT_RESOLVE || result == HTTPRequest.Result.RESULT_CANT_CONNECT || result == HTTPRequest.Result.RESULT_TIMEOUT):
		currently_online = false

		for i in http_request_nodes.values():
			i.cancel_request()
		return Result.new(
			false, {
				"error" : "Cannot connect to the Internet"
			}
		)
	currently_online = true
	var body_string = res[3] if (return_raw) else JSON.parse_string(res[3].get_string_from_utf8())
		
	# Server side Errors
	if (response_code != 200):
		var server_error = {
			"response_code" : response_code,
			"body_string" : body_string
		}
		printerr("Server Error Occured")
		printerr(server_error)
		return Result.new(
			false, server_error
		)
	return Result.new(
		true, {
			"body_string" : body_string
		}
	)
	
