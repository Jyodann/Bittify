extends Control

@export var size_of_headers = 18
@onready var scroll_box = $ScrollContainer/MarginContainer/VBoxContainer
@onready var log_out_button = $HBoxContainer/LogOut
@onready var check_box_component = preload("res://Components/checkbox_component.tscn")
@onready var player = preload("res://Pages/player_page.tscn")
@onready var launch_player = $HBoxContainer/LaunchMiniplayer
@onready var settings_dict = {
	"Window Settings" : {
		"Always on Top" : SettingBoundComponent.new(check_box_component, ApplicationStorage.Settings.PIN_TO_TOP),
	}
	
}

class SettingBoundComponent:
	var component
	var setting: ApplicationStorage.Settings

	func _init(_component, _setting):
		component = _component
		setting = _setting

# Called when the node enters the scene tree for the first time.
func _ready():
	log_out_button.pressed.connect(
		func():
			ApplicationStorage.modify_data(ApplicationStorage.Settings.ACCESS_TOKEN, "")
			ApplicationStorage.modify_data(ApplicationStorage.Settings.REFRESH_TOKEN, "")
			ContentPageShell.load_view(ContentPageShell.Page.LOGIN_PAGE)
			get_parent().queue_free()
	)

	launch_player.pressed.connect(
		func():
			var window = player.instantiate()

			window.title = "Player"
			get_tree().root.add_child(window)
	)

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
			var component = dictionary[i].component.instantiate()

			vbox.add_child(component)
			print("		SettingName: %s" % i)

			component._setup(i, dictionary[i].setting)
		
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_parent().queue_free()

		
