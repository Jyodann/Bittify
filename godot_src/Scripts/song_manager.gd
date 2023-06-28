extends Node

signal on_song_change(player_data: PlayerData)
var number_of_sessions = 0
var _timer = null
var is_ready = true
var access_token = ""

const TIME_BETWEEN_REFRESHES = 5

func _ready():
	access_token = get_access_token()
	_timer = Timer.new()
	add_child(_timer)
	_timer.timeout.connect(
		func():
			print("Attempt To Refresh")
			if (is_ready):
				on_song_change.emit(await _refresh_song())
	)
	_timer.set_wait_time(TIME_BETWEEN_REFRESHES)
	
	_timer.start()

	SongManager.on_song_change.connect(
		func(play_data):
			print("State: %s, Data: %s" % [play_data.player_state, play_data.data])
	)

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
	ACCESS_TOKEN_REFRESH_SUCESS
}

enum ResponseCodes {
	EXPIRED_TOKEN = 401,
	NO_SPOTIFY_SESSIONS = 204
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
	print("Starting Song Refresh")
	is_ready = false
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
			await get_tree().create_timer(5).timeout
			is_ready = true
			return PlayerData.new(
				PlayerState.ACCESS_TOKEN_REFRESH_FAILED
			)
		if (response_code == 204):
			is_ready = true
			return PlayerData.new(
				PlayerState.NO_SPOTIFY_SESSIONS
			)
		
	# Extract Data:
	var song_info = res.result.body_string
	var currently_playing_type = song_info.currently_playing_type
	is_ready = true
	if (currently_playing_type == PLAYING_TYPE_UNKNOWN):
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
	return PlayerData.new(
		PlayerState.SUCCESS, 
		{
			"name" : song_name,
			"album_name" : album_name,
			"artist_name" : artist_name,
			"cover_art_link" : cover_art_link,
			"external_url": external_link
		}
	)
	
	
	
