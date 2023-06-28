extends Node

signal on_song_change(player_data: PlayerData)
var number_of_sessions = 0
var _timer = null
var is_ready = true
var access_token = ""

var img_link_cache = ""
var cached_image = null
const CHANGE_DATA_SEC = 3
const DEFAULT_DELAY_SEC = 5
const CHECK_RATE_LIMIT_DELAY_SEC = 60
var previous_player_state = PlayerState.SUCCESS
func _ready():
	access_token = get_access_token()
	_timer = Timer.new()
	add_child(_timer)
	_timer.timeout.connect(
		func():
			
			if (is_ready):
				on_song_change.emit(await _refresh_song())
	)
	_timer.set_wait_time(CHANGE_DATA_SEC)
	
	_timer.start()


func get_refresh_token():
	return ApplicationStorage.get_data(ApplicationStorage.Settings.REFRESH_TOKEN)
	
func get_access_token():
	return ApplicationStorage.get_data(ApplicationStorage.Settings.ACCESS_TOKEN)

enum PlayerState {
	SUCCESS, 
	LOADING, 
	NOT_PLAYING, 
	NO_SPOTIFY_SESSIONS, 
	NO_OPEN_PLAYER_SESSIONS,
	OFFLINE, 
	ACCESS_TOKEN_REFRESH_FAILED,
	ACCESS_TOKEN_REFRESH_SUCESS,
	DOWNLOAD_ART_FAILED,
	RATE_LIMIT_OVERLOADED
}

enum ResponseCodes {
	EXPIRED_TOKEN = 401,
	NO_SPOTIFY_SESSIONS = 204,
	RATE_LIMIT_OVERLOADED = 429
}

const PLAYING_TYPE_UNKNOWN = "unknown"
const PLAYING_TYPE_PODCAST = "episode"
const PLAYING_TYPE_SONG = "track"

class PlayerData:
	var player_state: PlayerState
	var data: Dictionary

	func _init(_player_state: PlayerState, _data: Dictionary = {}):
		player_state = _player_state
		data = _data

func _refresh_song() -> PlayerData:
	

	is_ready = false

	if (previous_player_state == PlayerState.ACCESS_TOKEN_REFRESH_FAILED):
		await get_tree().create_timer(DEFAULT_DELAY_SEC).timeout
	
	if (previous_player_state == PlayerState.RATE_LIMIT_OVERLOADED):
		await get_tree().create_timer(CHECK_RATE_LIMIT_DELAY_SEC).timeout

	if (number_of_sessions == 0):
		is_ready = true
		return PlayerData.new(
			PlayerState.NO_OPEN_PLAYER_SESSIONS
		)
	var res = await NetworkRequests.currently_playing_song(access_token)
	
	if (!NetworkRequests.currently_online):
		is_ready = true
		return PlayerData.new(
			PlayerState.OFFLINE
		)
	
	if (!res.success):
		var response_code = res.result.response_code
		print(response_code)
		# Handle Expired Token:
		if (response_code == ResponseCodes.EXPIRED_TOKEN):
			var code = await NetworkRequests.get_new_access_token(get_refresh_token())
			
			if (code.success):
				ApplicationStorage.modify_data(ApplicationStorage.Settings.ACCESS_TOKEN, code.result.body_string.access_token)
				access_token = get_access_token()
				is_ready = true
				return PlayerData.new(
					PlayerState.ACCESS_TOKEN_REFRESH_SUCESS
				)
			# Wait 5 Seconds at least before next refresh:
			
			is_ready = true
			return PlayerData.new(
				PlayerState.ACCESS_TOKEN_REFRESH_FAILED
			)
		if (response_code == ResponseCodes.NO_SPOTIFY_SESSIONS):
			is_ready = true
			return PlayerData.new(
				PlayerState.NO_SPOTIFY_SESSIONS
			)
		if (response_code == ResponseCodes.RATE_LIMIT_OVERLOADED):
			is_ready = true
			return PlayerData.new(
				PlayerState.RATE_LIMIT_OVERLOADED
			)
		
	# Extract Data:
	var song_info = res.result.body_string
	var currently_playing_type = song_info.currently_playing_type
	
	if (currently_playing_type == PLAYING_TYPE_UNKNOWN):
		is_ready = true
		return PlayerData.new(
			PlayerState.LOADING
		)
	
	var song_root_item = song_info.item

	var song_name = song_root_item.name

	var external_link = song_root_item.external_urls.spotify

	var album_name = ""
	var artist_name = ""
	var cover_art_link = ""
	
	
	match (currently_playing_type):
		PLAYING_TYPE_PODCAST:
			var podcast_show = song_root_item.show

			album_name = podcast_show.publisher
			artist_name = podcast_show.name
			cover_art_link = song_root_item.images[0].url
		PLAYING_TYPE_SONG:
			album_name = song_root_item.album.name
			artist_name = ", ".join( 
				song_root_item.artists
						.map(
							func(current_artist):
								return current_artist.name)
				)
			cover_art_link = song_root_item.album.images[0].url
		_:
			printerr("Invalid Type: %s" % currently_playing_type)
	
	

	var data = {
		"name" : song_name,
		"album_name" : album_name,
		"artist_name" : artist_name,
		"cover_art_link" : cover_art_link,
		"external_url": external_link,
	}		

	if (cover_art_link != img_link_cache):
		var art_download = await NetworkRequests.download_album_art(cover_art_link)
		if (!art_download.success):
			is_ready = true
			return PlayerData.new(
				PlayerState.DOWNLOAD_ART_FAILED,
				data)
		is_ready = true
		img_link_cache = cover_art_link
		
		var downloaded_img_data = Image.new()
		downloaded_img_data.load_jpg_from_buffer(art_download.result.body_string)
		
		cached_image = downloaded_img_data
		data.img = downloaded_img_data
		return PlayerData.new(
			PlayerState.SUCCESS,
			data
		)
	is_ready = true
	data.img = cached_image
	return PlayerData.new(
			PlayerState.SUCCESS,
			data)
	
	
