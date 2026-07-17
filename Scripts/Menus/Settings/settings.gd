extends Control

@export var popup_mode = false

@onready var audio: VBoxContainer = %audio
@onready var video_settings: VBoxContainer = %video_settings
@onready var misc_settings: VBoxContainer = %misc_settings
@onready var warning: Label = %warning
@onready var fullscreen: CheckButton = %fullscreen

func _ready() -> void:
	load_settings()
	if popup_mode:
		get_parent().about_to_popup.connect(load_settings)

func load_settings() -> void:
	warning.hide()
	for k in Settings.audio:
		var node = audio.find_child(k.to_lower())
		if node is VolumeController:
			node.set_volume(Settings.audio[k] * 100.0)
	for k in Settings.video:
		var node = video_settings.find_child(k.to_lower())
		if node is CheckButton:
			node.set_pressed_no_signal(Settings.video[k])
	for k in Settings.misc:
		var node = misc_settings.find_child(k.to_lower())
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
		if child is CheckButton:
			Settings.video[child.name] = child.button_pressed
	for child in misc_settings.get_children():
		if child is CheckButton:
			Settings.misc[child.name] = child.button_pressed
	Settings.save_settings()
	Settings.apply_settings()
