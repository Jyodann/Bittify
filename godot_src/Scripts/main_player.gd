extends Control


@onready var main_song_title = $MainSongTitle
@onready var album_art = $AlbumArt
@onready var album_gradient = $AlbumGradient
@onready var disconnected_icon = preload("res://disconnected.png") 
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

	if (!NetworkRequests.currently_online):
		main_song_title.change_text("Not Connected. Attempting To Reconnect")
		if (album_art.texture != disconnected_icon):
			transition_art_texture(album_art, "texture", disconnected_icon)


			var gradient = GradientTexture2D.new()
			var gradientValues = Gradient.new()


			gradientValues.set_color(0, Color.BLACK)
			gradientValues.set_color(1, Color.BLACK)

			gradient.gradient = gradientValues

			transition_art_texture(album_gradient, "texture", gradient)
		await get_tree().create_timer(5).timeout

		refresh_song()
		return
	
	if (!res.success):
		print(res.result)
		var response_code = res.result.response_code
		# Handle Expired Token:
		if (response_code == 401):
			var code = await NetworkRequests.get_new_access_token(get_refresh_token())
			if (code.success):
				ApplicationStorage.modify_data(ApplicationStorage.ACCESS_TOKEN, code.result.body_string.access_token)
				access_token = get_access_token()
		# Song not playing / No Device Detected
		if (response_code == 204):
			main_song_title.change_text("Player currently not running")
		
		await get_tree().create_timer(1).timeout
		refresh_song()
		return 
	
	var song_info = get_metadata(res.result.body_string)
	
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
					#album_art.texture = art_download.result.texture

					var img = Image.new()
					img.load_jpg_from_buffer(art_download.result.body_string)
			
					var texture = ImageTexture.new()
					texture.set_image(img)
					
					var gradient = generate_gradient(img)



					transition_art_texture(album_gradient, "texture" ,gradient)

					transition_art_texture(album_art, "texture", texture)

					old_metadata = data
				
	await get_tree().create_timer(3).timeout

	refresh_song()


func transition_art_texture(texture_component: TextureRect, property_to_transit: String, object_to_trasit_to: Variant):
	var tween = get_tree().create_tween()
	tween.tween_property(texture_component, "modulate", Color.TRANSPARENT, .5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(texture_component, property_to_transit, object_to_trasit_to, 0)
	tween.tween_property(texture_component, "modulate", Color.WHITE, .25).set_trans(Tween.TRANS_CUBIC)

func generate_gradient(img: Image) -> GradientTexture2D:
	var gradient = GradientTexture2D.new()
	var gradientValues = Gradient.new()
	gradientValues.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
	var img_size = img.get_size()
	gradientValues.offsets = [
		0, .33, .5, .66, 1
	]
	
	var colors = []
	for i in range(gradientValues.offsets.size() - 1):
		var offset_value = gradientValues.offsets[i]
		print(offset_value)
		print(img_size.y * offset_value)
		var pixel = img.get_pixel(img_size.x / 2, img_size.y * offset_value)
		colors.append(pixel)

	colors.append(Color.BLACK)
	gradientValues.colors = colors

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

