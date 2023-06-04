extends Node

var http_request_nodes = {}
const CLIENT_ID = "9830ce611cad40ab98aaca36e75c0b79"

@onready var base_url = "http://127.0.0.1:8787" if OS.has_feature("debug") else "https://bittifybackend.jyodann.workers.dev"

@onready var redirect_url = "%s/callback" % base_url
@onready var get_token_url = "%s/get_access_token" % base_url

@onready var get_refresh_token_url = "%s/get_refresh_token" % base_url

@onready var oauth_url = "https://accounts.spotify.com/authorize?client_id=%s&response_type=code&redirect_uri=%s&scope=user-modify-playback-state user-read-currently-playing" % [CLIENT_ID, redirect_url]

class Result:
	var success: bool
	var result: Dictionary

	func _init(_success, _result):
		self.success = _success
		self.result = _result

func _ready():
	print("Initialiing all HTTPRequests")

func create_new_http_request_node(request_node_name: String):
	if (http_request_nodes.has(request_node_name)):
		return http_request_nodes[request_node_name]
	
	http_request_nodes[request_node_name] = HTTPRequest.new()
	add_child(http_request_nodes[request_node_name])
	return http_request_nodes[request_node_name]

func login_with_bittify_code(bittify_code: String):
	var client = create_new_http_request_node("bittify_login_code")
	var url = "%s?code=%s&redirect_url=%s" % [get_token_url, bittify_code, redirect_url]
	
	client.request(url)

	var res = await client.request_completed
	
	if (res[0] == 0):
		
		var json = JSON.parse_string(res[3].get_string_from_utf8())
		if(json.has("error_description")):
			return Result.new(false, {
				"error" : json["error_description"]
			})
		
		return Result.new(true, {
			"refresh_token" : json["refresh_token"], 
			"access_token" :json["access_token"] 
		})

		
	return Result.new(false, {
		"error" : "Failed to Connect to servers"
	})
		
#"https://api.spotify.com/v1/me/player/currently-playing?additional_types=episode,track"
func currently_playing_song(access_token: String):
	var client = create_new_http_request_node("currently_playing_song")
	var url = "https://api.spotify.com/v1/me/player/currently-playing?additional_types=episode,track"

	client.request( url, [
		"Authorization: Bearer %s" % access_token,
		"Content-Type: application/json"
	], HTTPClient.METHOD_GET)

	var res = await client.request_completed
	print(res[3].get_string_from_utf8())