extends "res://Scripts/settings_base.gd"

@onready var label = $MarginContainer/HBoxContainer/Label as Label
@onready var option_button = $MarginContainer/HBoxContainer/OptionButton as OptionButton

func _setup(name_of_setting, setting_to_track):
	super(name_of_setting, setting_to_track)

	label.text = name_of_setting
	
	var bindings = ApplicationStorage.get_settings_bindings(setting_to_track)
	for binding in bindings:
		
		var drop_down_info = bindings[binding]
		option_button.add_item(drop_down_info.displayedText, binding)

	option_button.item_selected.connect(
		func(selected_index):
			ApplicationStorage.modify_data(setting_to_track, selected_index)
	)
		
func _changed_setting(data) -> Variant:
	var change = super(data)
	
	if (!option_button.has_selectable_items()):
		return

	option_button.select(change)

	return change
	
