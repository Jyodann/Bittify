extends Control

@export var offset_between_text = 8.0

@onready var song_name_label = $HBoxContainer/song_name
@onready var duplicate_song_label = $duplicate_song_name

var is_animating = false
var is_duplicate_following = true

func _physics_process(_delta):
	if (song_name_label.size.x > size.x):
		is_animating = true
		duplicate_song_label.text = song_name_label.text
	else:
		is_animating = false
		duplicate_song_label.visible = false

	if (is_animating):
		duplicate_song_label.visible = true
		duplicate_song_label.size = song_name_label.size

		if (song_name_label.get_end().x < 0 or duplicate_song_label.get_end().x < 0):
			is_duplicate_following = !is_duplicate_following
		

		if (is_duplicate_following):
			song_name_label.position += Vector2(-0.5, 0)

			duplicate_song_label.position = Vector2(song_name_label.get_end().x + offset_between_text, 0)

		else:
			duplicate_song_label.position += Vector2(-0.5, 0)

			song_name_label.position = Vector2(duplicate_song_label.get_end().x + offset_between_text, 0)