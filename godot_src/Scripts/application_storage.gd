extends Node

@onready var BITTIFY_VERSION = "developer_version" if OS.get_environment("build_version") == "" else OS.get_environment("build_version")

const SAVE_FILE_PATH = "user://bittify_conf.cfg"


func _ready():
	_prep_data()
	_load_data()


signal on_settings_change(new_settings: Variant)

enum Settings {
	WIN_HEIGHT,
	WIN_WIDTH,
	WIN_POS_X,
	WIN_POS_Y,
	ACCESS_TOKEN,
	REFRESH_TOKEN,
	PIN_TO_TOP,
	SPEED_OF_SONG,
	BORDERLESS,
	PLAYER_LAUNCH_IMMEDIATELY,
	ALLOW_MORE_THAN_ONE_PLAYER,
	STYLE_OF_TEXT,
	CUSTOM_TEXT_STYLE
}

enum SpeedOfSong { SLOWEST, SLOW, DEFAULT, FAST, FASTEST }

enum StyleOfText {
	NAME_BY_ARTIST, NAME_DASH_ARTIST, NAME_BY_ARTIST_FROM_ALBUM, NAME_DASH_ARTIST_DASH_ALBUM, CUSTOM
}

var speed_of_song_bindings = {
	SpeedOfSong.SLOWEST: DropDownDisplay.new("Slowest", 20),
	SpeedOfSong.SLOW: DropDownDisplay.new("Slow", 30),
	SpeedOfSong.DEFAULT: DropDownDisplay.new("Default", 40),
	SpeedOfSong.FAST: DropDownDisplay.new("Fast", 55),
	SpeedOfSong.FASTEST: DropDownDisplay.new("Fastest", 70),
}

var style_of_text_bindings = {
	StyleOfText.NAME_BY_ARTIST:
	DropDownDisplay.new("Song Name by Artist", "`{song}` by `{artist}`"),
	StyleOfText.NAME_DASH_ARTIST:
	DropDownDisplay.new("Song Name - Artist", "`{song}` - `{artist}`"),
	StyleOfText.NAME_BY_ARTIST_FROM_ALBUM:
	DropDownDisplay.new("Song Name by Artist from Album", "`{song}` by `{artist}` from `{album}`"),
	StyleOfText.NAME_DASH_ARTIST_DASH_ALBUM:
	DropDownDisplay.new("Song Name - Artist - Album", "`{song}` - `{artist}` - `{album}`"),
	StyleOfText.CUSTOM: DropDownDisplay.new("Custom Style", "")
}

var settingsBindings = {
	Settings.SPEED_OF_SONG: speed_of_song_bindings, Settings.STYLE_OF_TEXT: style_of_text_bindings
}


class DropDownDisplay:
	var displayedText: String
	var value: Variant

	func _init(_displayedText: String, _value: Variant):
		displayedText = _displayedText
		value = _value


# Set Default Data:
var data = {}

var default_data = {
	Settings.WIN_HEIGHT: 350,
	Settings.WIN_WIDTH: 300,
	Settings.ACCESS_TOKEN: "",
	Settings.REFRESH_TOKEN: "",
	Settings.PIN_TO_TOP: false,
	Settings.SPEED_OF_SONG: SpeedOfSong.DEFAULT,
	Settings.BORDERLESS: false,
	Settings.WIN_POS_X: 300,
	Settings.WIN_POS_Y: 300,
	Settings.PLAYER_LAUNCH_IMMEDIATELY: false,
	Settings.ALLOW_MORE_THAN_ONE_PLAYER: false,
	Settings.STYLE_OF_TEXT: StyleOfText.NAME_DASH_ARTIST,
	Settings.CUSTOM_TEXT_STYLE: "`{song}` * `{artist}` * `{album}`",
}


func _prep_data():
	for i in default_data:
		data[_convert_enum_to_str(i)] = default_data[i]


func _save_data() -> void:
	var config = ConfigFile.new()

	for key in data:
		var value_to_save = data[key]
		config.set_value("bittify", key, value_to_save)

	config.save(SAVE_FILE_PATH)


func _load_data() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_FILE_PATH)

	if err != OK:
		_save_data()
		_load_data()
		return

	for i in config.get_section_keys("bittify"):
		var data_key = i
		var data_value = config.get_value("bittify", i)
		print("Loaded Setting: %s" % data_key)
		data[data_key] = data_value


func get_data(key: Settings):
	var enum_in_str = _convert_enum_to_str(key)
	if !data.has(enum_in_str):
		printerr("Invalid Key %s" % key)
		return
	return data[enum_in_str]


func modify_data(key: Settings, value: Variant, emit_changes_signal: bool = true) -> void:
	var enum_in_str = _convert_enum_to_str(key)
	if !data.has(enum_in_str):
		printerr("Invalid Key %s" % key)
		return

	data[enum_in_str] = value
	if emit_changes_signal:
		on_settings_change.emit(data)

	_save_data()


func _convert_enum_to_str(key: Settings) -> String:
	return Settings.keys()[key]


func _convert_string_to_enum(key: String) -> Settings:
	return Settings.get(key)


func filter_emit_data(emit_data: Variant, key: Settings) -> Variant:
	return emit_data[_convert_enum_to_str(key)]


func force_emit_data() -> void:
	on_settings_change.emit(data)


func get_settings_bindings(key: Settings) -> Dictionary:
	return settingsBindings[key]
