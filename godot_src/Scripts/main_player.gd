extends Control


@onready var main_song_title = $MainSongTitle

# Called when the node enters the scene tree for the first time.
func _ready():
	main_song_title.change_text("Hello there, what time is it?")
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
