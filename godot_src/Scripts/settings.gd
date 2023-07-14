extends Control

@export var size_of_headers = 24
@onready var scroll_box = $ScrollContainer/MarginContainer/VBoxContainer
@onready var log_out_button = $HBoxContainer/LogOut
@onready var about_button = $HBoxContainer/About
@onready var check_box_component = preload("res://Components/checkbox_component.tscn")
@onready var dropdown_box_component = preload("res://Components/drop_down_box_component.tscn")
@onready var textedit_box_component = preload("res://Components/text_edit_component.tscn")
@onready var about_page = preload("res://Pages/about_window.tscn")
@onready var settings_dict = {
	"Window Settings" : {
		"Always on Top" : SettingBoundComponent.new(check_box_component, ApplicationStorage.Settings.PIN_TO_TOP),
	},
	"Player Settings" : {
		"Show Adaptive Background": SettingBoundComponent.new(check_box_component, ApplicationStorage.Settings.ADAPTIVE_BACKGROUND),
	},
	"Text Settings" : {
		"Text Overflow Scroll Speed" : SettingBoundComponent.new(dropdown_box_component, ApplicationStorage.Settings.SPEED_OF_SONG),
		"Display Style (Updates within 3s)" : SettingBoundComponent.new(dropdown_box_component, ApplicationStorage.Settings.STYLE_OF_TEXT),
		"Custom Display Style" : SettingBoundComponent.new(textedit_box_component, ApplicationStorage.Settings.CUSTOM_TEXT_STYLE)
	},
	"Experimental Features" : {
		"Borderless Player (Applies on Restart)" : SettingBoundComponent.new(check_box_component, ApplicationStorage.Settings.BORDERLESS),
	}
}

@onready var player_windows = []

var old_borderless_setting : bool

class SettingBoundComponent:
	var component
	var setting: ApplicationStorage.Settings

	func _init(_component, _setting):
		component = _component
		setting = _setting


func on_about_pressed():
	if (get_tree().get_root().has_node("about_window")):
		get_tree().get_root().get_node("about_window").move_to_foreground()
		return
	var window = about_page.instantiate()
	get_tree().get_root().add_child(window)
# Called when the node enters the scene tree for the first time.
func _ready():
	WindowFunctions.change_window_title("Settings", get_window())
	log_out_button.pressed.connect(
		func():
			ApplicationStorage.modify_data(ApplicationStorage.Settings.ACCESS_TOKEN, "")
			ApplicationStorage.modify_data(ApplicationStorage.Settings.REFRESH_TOKEN, "")
			get_window().queue_free()
			SongManager.number_of_sessions = 0
			ContentPageShell.load_view(ContentPageShell.Page.LOGIN_PAGE)
			get_parent().queue_free()
	)

	about_button.pressed.connect(
		on_about_pressed
	)



	old_borderless_setting = ApplicationStorage.get_data(ApplicationStorage.Settings.BORDERLESS)
	
	for setting_header in settings_dict:
		var label = Label.new()
		label.text = setting_header
		label.add_theme_font_size_override("font_size", size_of_headers)
		scroll_box.add_child(label)
		

		var dictionary = settings_dict[setting_header]

		var vbox = VBoxContainer.new()

		scroll_box.add_child(vbox)
		for i in dictionary:
			var component = dictionary[i].component.instantiate()

			vbox.add_child(component)
			component._setup(i, dictionary[i].setting)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_window().queue_free()
			
