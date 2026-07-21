extends Control

@export var popup_mode = false

@onready var audio: VBoxContainer = %audio
@onready var video_settings: VBoxContainer = %video_settings
@onready var misc_settings: VBoxContainer = %misc_settings
@onready var warning: Label = %warning
@onready var calibrate: Button = %calibrate

func _ready() -> void:
	load_settings()
	if popup_mode:
		calibrate.hide()
		get_parent().about_to_popup.connect(reload_settings)

func reload_settings() -> void:
	for child in video_settings.get_children():
		child.queue_free()
	for child in misc_settings.get_children():
		child.queue_free()
	load_settings()

func load_settings() -> void:
	warning.hide()
	for k in Settings.audio:
		var node = audio.find_child(k.to_lower())
		if node is VolumeController:
			node.set_volume(Settings.audio[k] * 100.0)
	for k in Settings.video:
		var value = Settings.video[k]
		var node
		if value is bool:
			node = CheckButton.new()
			node.name = k
			node.text = k.capitalize()
			video_settings.add_child(node)
			node.set_meta("key", k)
			node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if node is CheckButton:
			node.set_pressed_no_signal(Settings.video[k])
	for k in Settings.misc:
		var value = Settings.misc[k]
		if not value is bool:
			continue
		var node = CheckButton.new()
		node.name = k
		node.text = k.capitalize()
		misc_settings.add_child(node)
		misc_settings.move_child(node, misc_settings.get_child_count() - 2)
		node.set_meta("key", k)
		node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if node is CheckButton:
			node.set_pressed_no_signal(Settings.misc[k])

func _on_back_pressed() -> void:
	if not popup_mode:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		return
	get_parent().hide()

func _on_apply_pressed() -> void:
	for child in audio.get_children():
		if child is VolumeController:
			Settings.audio[child.bus] = child.linear_volume
	for child in video_settings.get_children():
		var key = child.get_meta("key", "")
		if child is CheckButton:
			Settings.video[key] = child.button_pressed
	for child in misc_settings.get_children():
		var key = child.get_meta("key", "")
		if child is CheckButton:
			Settings.misc[key] = child.button_pressed
	Settings.save_settings()
	Settings.apply_settings()

func _on_calibrate_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/Calibration/calibration.tscn")

func _on_restore_beatmaps_pressed() -> void:
	Globals.restore_starter_beatmaps()
