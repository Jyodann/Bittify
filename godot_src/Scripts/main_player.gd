extends Control


@onready var main_song_title = $MainSongTitle
@onready var album_art = $AlbumArt
@onready var album_gradient = $AlbumGradient
enum {
	SUCCESS, LOADING, NOT_PLAYING
}

func get_refresh_token():
	return ApplicationStorage.get_data(ApplicationStorage.REFRESH_TOKEN)

func get_access_token():
	return ApplicationStorage.get_data(ApplicationStorage.ACCESS_TOKEN)

var access_token = "";

var old_metadata = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	main_song_title.change_text("Hello there, what time is it?")
	access_token = get_access_token()

	refresh_song()
	
	

func refresh_song():
	var res = await NetworkRequests.currently_playing_song(access_token)

	if (!res.success):

		if (res.result.error == "Token Expired"):
			
			var code = await NetworkRequests.get_new_access_token(get_refresh_token())
			if (code.success):
				ApplicationStorage.modify_data(ApplicationStorage.ACCESS_TOKEN, code.result.access_token)
				access_token = get_access_token()
			
		await get_tree().create_timer(1).timeout
		refresh_song()
		return 
	
	var song_info = get_metadata(res.result)
	
	match (song_info.state):
		NOT_PLAYING:
			main_song_title.change_text("Player currently not running")
			pass
		LOADING:
			main_song_title.change_text("Loading Song...")
			pass
		SUCCESS:
			var data = song_info.metadata
			
			if (old_metadata != data):
				var title = "%s by %s from %s" % [data.name, data.artist_name, data.album_name]
				main_song_title.change_text(title)
				WindowFunctions.change_window_title(title)
				var art_download = await NetworkRequests.download_album_art(data.cover_art_link)
				
				if (art_download.success):
					album_art.texture = art_download.result.texture
					album_gradient.texture = generate_gradient(art_download.result.raw_image)

					old_metadata = data
				
	await get_tree().create_timer(1).timeout

	refresh_song()

func generate_gradient(img: Image) -> GradientTexture2D:
	var gradient = GradientTexture2D.new()
	var gradientValues = Gradient.new()

	var img_size = img.get_size()

	gradientValues.set_color(0, img.get_pixel(img_size.x / 2, img_size.y / 2))
	gradientValues.set_color(1, Color.BLACK)

	gradient.fill_from = Vector2.ZERO
	gradient.fill_to = Vector2(0, 1)

	gradient.gradient = gradientValues

	return gradient

func get_metadata(json):
	if (json.is_empty()):
		return {
			"state" : NOT_PLAYING,
			"metadata" : {}
		}
	
	var currently_playing_type = json.currently_playing_type

	if (currently_playing_type == "unknown"):
		return {
			"state" : LOADING,
			"metadata" : {}
		}

	var item = json.item
	var song_name = item.name

	var external_link = item.external_urls.spotify
	var is_song_playing = json.is_playing

	var album_name = ""
	var artist_name = ""
	var cover_art_link = ""

	
	match (currently_playing_type):
		"episode":
			var podcast_show = item.show

			album_name = podcast_show.publisher
			artist_name = podcast_show.name
			cover_art_link = item.images[0].url

			pass
		"track":
			album_name = item.album.name
			
			artist_name = ", ".join( 
					item.artists
					.map(
						func(current_artist):
							return current_artist.name)
			)

			cover_art_link = item.album.images[0].url
			pass
		_ :
			printerr("Invalid Type: %s" % currently_playing_type)
	return { 
		"state" : SUCCESS, 
		"metadata" : 
			{
			"name" : song_name,
			"album_name" : album_name,
			"artist_name" : artist_name,
			"cover_art_link" : cover_art_link,
			"external_url": external_link
			} 
		}

