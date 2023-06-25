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

func change_checked_state(checked_state, emit_change_signal: bool = false):
	checked = checked_state
	if (emit_change_signal):
		on_checked.emit(checked)
	change_textures(checked)

func check_button():
	checked = !checked
	on_checked.emit(checked)
	

func change_textures(changed_state):
	texture_button.texture_normal = checked_texture if changed_state else unchecked_texture
