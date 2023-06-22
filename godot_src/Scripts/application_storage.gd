extends Node

const SAVE_FILE_PATH = "user://config.bittisave"

func _ready():
	load_data()

const WIN_HEIGHT = "win_height"
const WIN_WIDTH = "win_width"
const ACCESS_TOKEN = "token"
const REFRESH_TOKEN = "refresh"
const PIN_TO_TOP = "pinned"

# Set Default Data:
var data = {
	WIN_HEIGHT : 350, 
	WIN_WIDTH : 300,
	ACCESS_TOKEN : "",
	REFRESH_TOKEN : "",
    PIN_TO_TOP : false
}

func save_data(): 
	var config = ConfigFile.new()

	for key in data:
		var value_to_save = data[key]
		config.set_value("bittify", key, value_to_save)

	config.save(SAVE_FILE_PATH)

func load_data():
	var config = ConfigFile.new()
	var err = config.load(SAVE_FILE_PATH)

	if err != OK:
		print("Creating new Data")
		save_data()
		load_data()
		return
	
	for i in config.get_section_keys("bittify"):
		var data_key = i
		var data_value = config.get_value("bittify", i)
		print(data_key)
		data[data_key] = data_value
	
func get_data(key): 
	if (!data.has(key)):
		printerr("Invalid Key %s" % key)
		return
	return data[key]

func modify_data(key, value):
	if (!data.has(key)):
		printerr("Invalid Key %s" % key)
		return
	data[key] = value
	save_data()
