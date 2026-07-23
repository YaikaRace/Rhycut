extends Control

@onready var calibration_viewport: Node2D = %calibration_viewport
@onready var current_offset_label: Label = %current_offset

@onready var current_offset = 0.0

func _ready() -> void:
	calibration_viewport.offset = Settings.calibration.offset

func _process(delta: float) -> void:
	calibration_viewport.offset = clampf(calibration_viewport.offset, -0.5, 0.5)
	current_offset = calibration_viewport.offset
	current_offset_label.text = "Current Offset: %sms" % str(floori(current_offset * 1000))

func _on_sub_1_pressed() -> void:
	calibration_viewport.offset -= 0.1

func _on_sub_0_1_pressed() -> void:
	calibration_viewport.offset -= 0.05

func _on_sub_0_01_pressed() -> void:
	calibration_viewport.offset -= 0.01

func _on_add_0_01_pressed() -> void:
	calibration_viewport.offset += 0.01

func _on_add_0_1_pressed() -> void:
	calibration_viewport.offset += 0.05

func _on_add_1_pressed() -> void:
	calibration_viewport.offset += 0.1

func _on_apply_pressed() -> void:
	Settings.calibration.offset = current_offset
	Settings.save_settings()
	GameState.reset_state()
	AudioHelper.stop_game()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
