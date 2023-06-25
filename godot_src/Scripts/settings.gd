extends Control
@export var size_of_headers = 18
@onready var scroll_box = $ScrollContainer/MarginContainer/VBoxContainer
@onready var check_box_component = preload("res://Components/checkbox_component.tscn")
@onready var settings_dict = {
	"Window Settings" : {
		"Always on Top" : check_box_component,
		"Here with you" : check_box_component
	}
	
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for setting_header in settings_dict:
		var label = Label.new()
		label.text = setting_header
		label.add_theme_font_size_override("font_size", size_of_headers)
		scroll_box.add_child(label)
		print("Setting Header: %s" % setting_header)

		var dictionary = settings_dict[setting_header]

		var vbox = VBoxContainer.new()

		scroll_box.add_child(vbox)
		for i in dictionary:
			var component = dictionary[i].instantiate()

			vbox.add_child(component)
			print("		SettingName: %s" % i)

			component._setup(i)
		
			
			
		
