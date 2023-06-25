extends Node

const SAVE_FILE_PATH = "user://bittify_conf.cfg"

func _ready():
	_load_data()

signal on_settings_change(args)

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
	Settings.WIN_HEIGHT : 350, 
	Settings.WIN_WIDTH : 300,
	Settings.ACCESS_TOKEN : "",
	Settings.REFRESH_TOKEN : "",
	Settings.PIN_TO_TOP : false,
	Settings.SPEED_OF_SONG : 1.0
}

func _save_data() -> void: 
	var config = ConfigFile.new()

	for key in data:
		var value_to_save = data[key]
		config.set_value("bittify", str(key), value_to_save)

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
		data[data_key] = data_value
	
func get_data(key: Settings): 
	print(key)
	if (!data.has(key)):
		printerr("Invalid Key %s" % key)
		return
	return data[key]

func modify_data(key: Settings, value: Variant, emit_changes_signal: bool = true) -> void:
	if (!data.has(key)):
		printerr("Invalid Key %s" % key)
		return
	
	data[key] = value
	if (emit_changes_signal):
		on_settings_change.emit(data)
	
	_save_data()
