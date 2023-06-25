extends "res://Scripts/settings_base.gd"

@onready var label = $"MarginContainer/HBoxContainer/Label" as Label
@onready var check_button = $"MarginContainer/HBoxContainer/CheckButton"

func _setup(name_of_setting, setting_to_track):
	super(name_of_setting, setting_to_track)

	label.text = name_of_setting

	check_button.pressed.connect(
		func():
			WindowFunctions.change_window_always_on_top(check_button.button_pressed)
			ApplicationStorage.modify_data(setting_to_track, check_button.button_pressed)
	)


func _changed_setting(data) -> Variant:
	var change = super(data)

	check_button.button_pressed = change
	return change