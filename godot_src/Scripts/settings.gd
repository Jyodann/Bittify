extends Control
@export var size_of_headers = 18
@onready var scroll_box = $ScrollContainer/MarginContainer/VBoxContainer
@onready var check_box_component = preload("res://Scenes/checkbox_component.tscn")
var settings_dict = {
	"Window Settings" : {
		"hello" : check_box_component.new()
	}, 
	"Language" : {

	}, 
	"Text Display" : {
		"" : ""
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for setting_header in settings_dict:
		var label = Label.new()
		label.text = setting_header
		label.add_theme_font_size_override("font_size", size_of_headers)
		scroll_box.add_child(label)
