extends AcceptDialog

@onready var mod_container: GridContainer = %mod_container

var selected = []
var unselected = []

func _ready() -> void:
	get_ok_button().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	load_modifiers()
	for button in mod_container.get_children():
		button.toggled.connect(_on_mod_toggled.bind(button.name))

func load_modifiers() -> void:
	for button in mod_container.get_children():
		button.set_pressed_no_signal(false)
	for mod in GameState.modifiers:
		var button = mod_container.find_child(mod)
		button.set_pressed_no_signal(true)

func _on_mod_toggled(toggled_on: bool, button_name: String) -> void:
	if toggled_on:
		GameState.modifiers.append(button_name)
	else:
		if button_name in GameState.modifiers:
			GameState.modifiers.erase(button_name)

func _on_about_to_popup() -> void:
	load_modifiers()
