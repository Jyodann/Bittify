extends Node

const SAVE_FILE_PATH = "user://bittify_conf.cfg"

func _ready():
	_prep_data()
	_load_data()

signal on_settings_change(new_settings: Variant)

enum Settings {
	WIN_HEIGHT, 
	WIN_WIDTH,
	ACCESS_TOKEN, 
	REFRESH_TOKEN,
	PIN_TO_TOP,
	SPEED_OF_SONG
}

# Set Default Data:
var data = {
	
}

var default_data = {
	Settings.WIN_HEIGHT : 350, 
	Settings.WIN_WIDTH : 300,
	Settings.ACCESS_TOKEN : "",
	Settings.REFRESH_TOKEN : "",
	Settings.PIN_TO_TOP : false,
	Settings.SPEED_OF_SONG : 1.0
}

func _prep_data():
	for i in default_data:
		data[_convert_enum_to_str(i)] = default_data[i]

func _save_data() -> void: 
	print("Saving Data")
	var config = ConfigFile.new()

	for key in data:
		var value_to_save = data[key]
		config.set_value("bittify", key, value_to_save)

	config.save(SAVE_FILE_PATH)

func _load_data() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_FILE_PATH)

	if err != OK:
		print("Creating new Data")
		_save_data()
		_load_data()
		return
	
	for i in config.get_section_keys("bittify"):
		var data_key = i
		var data_value = config.get_value("bittify", i)
		print("Loaded Setting: %s : %s" % [data_key, data_value])
		data[data_key] = data_value
	
func get_data(key: Settings): 
	var enum_in_str = _convert_enum_to_str(key)
	if (!data.has(enum_in_str)):
		printerr("Invalid Key %s" % key)
		return
	return data[enum_in_str]

func modify_data(key: Settings, value: Variant, emit_changes_signal: bool = true) -> void:
	var enum_in_str = _convert_enum_to_str(key)
	if (!data.has(enum_in_str)):
		printerr("Invalid Key %s" % key)
		return
	
	data[enum_in_str] = value
	if (emit_changes_signal):
		on_settings_change.emit(data)
	
	_save_data()

func _convert_enum_to_str(key: Settings) -> String:
	return Settings.keys()[key]

func _convert_string_to_enum(key: String) -> Settings:
	return Settings.get(key)

func filter_emit_data(emit_data: Variant, key: Settings) -> Variant:
	return emit_data[_convert_enum_to_str(key)]
