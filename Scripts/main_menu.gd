extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/Level Selection/level_selection.tscn")

func _on_editor_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Editor/editor.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/Settings/settings.tscn")
