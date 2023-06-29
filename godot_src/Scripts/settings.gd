extends Control

@export var size_of_headers = 18
@onready var scroll_box = $ScrollContainer/MarginContainer/VBoxContainer
@onready var log_out_button = $HBoxContainer/LogOut
@onready var check_box_component = preload("res://Components/checkbox_component.tscn")
@onready var player = preload("res://Pages/player_page.tscn")
@onready var launch_player = $HBoxContainer/LaunchMiniplayer
@onready var settings_dict = {
	"Window Settings" : {
		"Launch Player on Start" : SettingBoundComponent.new(check_box_component, ApplicationStorage.Settings.PLAYER_LAUNCH_IMMEDIATELY),
		"Always on Top" : SettingBoundComponent.new(check_box_component, ApplicationStorage.Settings.PIN_TO_TOP),
		
	},
	"Experimental Features" : {
		"Allow multiple Miniplayers" : SettingBoundComponent.new(check_box_component, ApplicationStorage.Settings.ALLOW_MORE_THAN_ONE_PLAYER),
		"Borderless Player" : SettingBoundComponent.new(check_box_component, ApplicationStorage.Settings.BORDERLESS),
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

func open_new_player_window():
	if (ApplicationStorage.get_data(ApplicationStorage.Settings.ALLOW_MORE_THAN_ONE_PLAYER) || SongManager.number_of_sessions < 1):
		SongManager.number_of_sessions += 1
		var window = player.instantiate()

		window.title = "Bittify Miniplayer"
		
		get_tree().root.add_child(window)
		player_windows.append(window)
		WindowFunctions.minimize_window()

func on_settings_change(new_settings): 
	var is_borderless = ApplicationStorage.filter_emit_data(new_settings, ApplicationStorage.Settings.BORDERLESS)

	if (is_borderless != old_borderless_setting):
		old_borderless_setting = is_borderless
		var any_window_exists = !player_windows.is_empty()
		print(any_window_exists)
		for window in player_windows:
			window.queue_free()
		player_windows.clear()
		SongManager.number_of_sessions = 0
		if (any_window_exists):
			open_new_player_window()
		
	
		
	


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
		open_new_player_window
	)

	ApplicationStorage.on_settings_change.connect(
		on_settings_change
	)
	old_borderless_setting = ApplicationStorage.get_data(ApplicationStorage.Settings.BORDERLESS)

	if (ApplicationStorage.get_data(ApplicationStorage.Settings.PLAYER_LAUNCH_IMMEDIATELY)):
		open_new_player_window()
	
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
		


		
