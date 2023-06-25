extends Control

var setting: ApplicationStorage.Settings
func _setup(_name_of_setting: String, setting_to_track: ApplicationStorage.Settings) -> void:
	setting = setting_to_track
	ApplicationStorage.on_settings_change.connect(
		_changed_setting
	)

	ApplicationStorage.force_emit_data()

func _changed_setting(data) -> Variant:
	return ApplicationStorage.filter_emit_data(data, setting)
