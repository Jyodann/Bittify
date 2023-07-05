extends "res://Scripts/settings_base.gd"

@onready var label = $MarginContainer/HBoxContainer/Label as Label
@onready var text_edit = $MarginContainer/HBoxContainer/HBoxContainer/EditText as TextEdit
@onready var save_button = $MarginContainer/HBoxContainer/HBoxContainer/SaveButton as Button


func _setup(name_of_setting, setting_to_track):
	super(name_of_setting, setting_to_track)

	label.text = name_of_setting
	save_button.pressed.connect(
		func(): ApplicationStorage.modify_data(
			ApplicationStorage.Settings.CUSTOM_TEXT_STYLE, text_edit.text
		)
	)


func _changed_setting(data) -> Variant:
	var change = super(data)

	text_edit.text = change

	return change
