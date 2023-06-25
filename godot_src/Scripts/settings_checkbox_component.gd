extends "res://Scripts/settings_base.gd"

@onready var label = $"MarginContainer/HBoxContainer/Label" as Label
@onready var check_button = $"MarginContainer/HBoxContainer/CheckButton"

func _setup(name_of_setting):
	super(name_of_setting)

	label.text = name_of_setting
