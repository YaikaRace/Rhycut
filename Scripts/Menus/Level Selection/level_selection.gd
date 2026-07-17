extends Control

const LEVEL_BUTTON = preload("uid://dsm3cf3vr0c4c")

@export_dir var path: String = "user://beatmaps"

@onready var levels_container: VBoxContainer = %levels_container
@onready var level_info: VBoxContainer = %level_info
@onready var panel_container: PanelContainer = %PanelContainer
@onready var audio_player: AudioStreamPlayer = %audio_player

func _ready() -> void:
	if OS.get_name() == "Web":
		path = "res://Starter Beatmaps"
	load_beatmaps()

func load_beatmaps() -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path("user://beatmaps")):
		return
	var dir = DirAccess.open(path)
	for file in dir.get_files():
		if file.get_extension() != "rcbm":
			continue
		var f = FileAccess.open(path.path_join(file), FileAccess.READ)
		var metadata = f.get_var()
		var data = f.get_var()
		f.close()
		var ins = LEVEL_BUTTON.instantiate()
		ins.level_path = path.path_join(file)
		levels_container.add_child(ins)
		ins.pressed.connect(_on_beatmap_selected.bind(data))
		if file == Globals.current_dropped:
			ins.grab_focus()
			Globals.current_dropped = ""
		ins.set_data(metadata)

func reload_beatmaps() -> void:
	for child in levels_container.get_children():
		child.queue_free()
	load_beatmaps()

func _on_beatmap_selected(mdata: Dictionary, data: Dictionary) -> void:
	level_info.set_metadata(mdata)
	var audio: AudioStream
	if data.audio_type == "mp3":
		audio = AudioStreamMP3.load_from_buffer(data.audio)
	elif data.audio_type == "ogg":
		audio = AudioStreamOggVorbis.load_from_buffer(data.audio)
	elif data.audio_type == "wav":
		audio = AudioStreamWAV.load_from_buffer(data.audio)
	audio_player.stream = audio
	audio_player.play()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_open_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://beatmaps"))

func _on_refresh_button_pressed() -> void:
	reload_beatmaps()
