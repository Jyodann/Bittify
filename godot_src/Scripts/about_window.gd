extends Control

@onready var build_info_label = $VBoxContainer/About_Section/bittify_build_info
@onready
var licences_info_label = $VBoxContainer/OpenSource_Section/ScrollContainer/VBoxContainer/bittify_licence
@onready var gd_label = $VBoxContainer/About_Section/bittify_godot_info

@onready var email_button = $VBoxContainer/Support_Section/HBoxContainer/Email
@onready var pull_request_button = $VBoxContainer/Support_Section/HBoxContainer/PullReq
@onready var github_source_button = $VBoxContainer/Support_Section/HBoxContainer2/GitSource
@onready var donate_button = $VBoxContainer/Support_Section/HBoxContainer3/Donate
@onready var check_for_updates_button = $VBoxContainer/CheckForUpdatesButton
@onready var OS_NAME = OS.get_name()
@onready var ARCHITECTURE_NAME = Engine.get_architecture_name()
@onready var ENGINE_VERSION = Engine.get_version_info().string

@onready var ENGINE_LICENCE = Engine.get_license_text()
@onready var ENGINE_LICENCE_INFO = Engine.get_license_info()

@onready var version = preload("res://version.gd").VERSION
@onready var licences = [
	Licence.new("Godot Engine", ENGINE_LICENCE, "www.godot.com"),
	Licence.new("Godot Engine Third Party Licences", "\n", ""),
]


# Called when the node enters the scene tree for the first time.
func _ready():

	WindowFunctions.change_window_title("About", get_window())
	github_source_button.pressed.connect(
		func(): OS.shell_open("https://github.com/Jyodann/Bittify")
	)

	email_button.pressed.connect(func(): OS.shell_open("mailto:jordynwinnie@gmail.com"))

	pull_request_button.pressed.connect(
		func(): OS.shell_open("https://github.com/Jyodann/Bittify/pulls")
	)

	check_for_updates_button.pressed.connect(
		func(): OS.shell_open("https://github.com/Jyodann/Bittify/releases")
	)

	donate_button.pressed.connect(func(): OS.shell_open("https://ko-fi.com/jyodann"))

	build_info_label.text = "Bittify for %s (%s) v%s" % [OS_NAME, ARCHITECTURE_NAME, version]
	gd_label.text = "Godot Version: %s" % [ENGINE_VERSION]

	for i in ENGINE_LICENCE_INFO:
		licences.append(Licence.new(i, ENGINE_LICENCE_INFO[i], ""))

	licences_info_label.push_normal()
	licences_info_label.add_text("\n")

	for i in licences:
		licences_info_label.push_bold()
		licences_info_label.add_text(i.heading)
		licences_info_label.add_text("\n")
		licences_info_label.push_normal()
		licences_info_label.add_text(i.licence_info)
		licences_info_label.push_normal()
		licences_info_label.add_text("\n")


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_window().queue_free()


class Licence:
	var heading
	var licence_info
	var link_or_site

	func _init(_heading, _licence_info, _link_or_site):
		heading = _heading
		licence_info = _licence_info
		link_or_site = _link_or_site
