extends Control

@onready var build_info_label = $VBoxContainer/bittify_build_info
@onready var version_info_label = $VBoxContainer/bittify_version_info
@onready var licences_info_label = $VBoxContainer/bittify_licence

@onready var OS_NAME = OS.get_name()
@onready var ARCHITECTURE_NAME = Engine.get_architecture_name()
@onready var ENGINE_VERSION = Engine.get_version_info().string

@onready var ENGINE_LICENCE = Engine.get_license_text()
@onready var ENGINE_LICENCE_INFO = Engine.get_license_info() 
@onready var licences = [
	Licence.new("Godot Engine", ENGINE_LICENCE, "www.godot.com"),
	Licence.new("Godot Engine Third Party Licences", "\n", ""),
]
# Called when the node enters the scene tree for the first time.
func _ready():
	build_info_label.text = "Bittify for %s (%s)" % [OS_NAME, ARCHITECTURE_NAME]

	version_info_label.text = "v%s built with %s" % ["0.1", ENGINE_VERSION]
	print(Engine.get_copyright_info())

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
		
	
	
	


class Licence:
	var heading
	var licence_info
	var link_or_site

	func _init(_heading, _licence_info, _link_or_site):
		heading = _heading
		licence_info = _licence_info
		link_or_site = _link_or_site
