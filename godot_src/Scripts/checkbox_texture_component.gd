extends Control

signal on_checked(checked_state)

@export var unchecked_texture: Texture
@export var checked_texture: Texture
@onready var texture_button: TextureButton = $TextureButton

var checked = false
func _ready():
	texture_button.texture_normal = unchecked_texture
	texture_button.pressed.connect(check_button)
	on_checked.connect(change_textures)

func set_checked(checked_state):
	checked = checked_state
	on_checked.emit(checked)
	

func check_button():
	checked = !checked
	on_checked.emit(checked)
	

func change_textures(changed_state):
	texture_button.texture_normal = checked_texture if changed_state else unchecked_texture
