extends CanvasLayer

@export var is_editor = false

@onready var settings_popup: Window = %settings_popup
@onready var restart_level_button: Button = %restart_level

func _ready() -> void:
	if is_editor:
		restart_level_button.hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_game"):
		if settings_popup.visible:
			settings_popup.hide()
		else:
			get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	if Input.is_action_just_pressed("restart"):
		restart_level()

func restart_level() -> void:
	if is_editor: return
	get_tree().paused = false
	GameState.reset_level()
	get_tree().reload_current_scene()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	settings_popup.hide()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	GameState.reset_state()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_settings_pressed() -> void:
	settings_popup.popup_centered()

func _on_restart_level_pressed() -> void:
	restart_level()
