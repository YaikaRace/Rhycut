extends Control

const LEVEL_BUTTON = preload("uid://dsm3cf3vr0c4c")

@export_dir var path: String = "user://beatmaps"

@onready var levels_container: VBoxContainer = %levels_container
@onready var level_info: VBoxContainer = %level_info
@onready var panel_container: PanelContainer = %PanelContainer
@onready var audio_player: AudioStreamPlayer = %audio_player
@onready var modifiers_popup: AcceptDialog = %modifiers_popup
@onready var manage_popup: AcceptDialog = %manage
@onready var share: Share = %Share

var current_beatmap_path = ""

func _ready() -> void:
	if OS.get_name() == "Web":
		path = "res://Starter Beatmaps"
	load_beatmaps()

func load_beatmaps(exclude: Array = []) -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path("user://beatmaps")):
		return
	var dir = DirAccess.open(path)
	for file in dir.get_files():
		if file in exclude:
			continue
		if file.get_extension() != "rcbm":
			continue
		var f = FileAccess.open(path.path_join(file), FileAccess.READ)
		var metadata = f.get_var()
		var data = {}
		if Settings.misc.level_music_in_selection:
			data = f.get_var()
		f.close()
		var ins = LEVEL_BUTTON.instantiate()
		ins.level_path = path.path_join(file)
		levels_container.add_child(ins)
		ins.pressed.connect(_on_beatmap_selected.bind(data, ProjectSettings.globalize_path(path.path_join(file))))
		if file == Globals.current_dropped:
			ins.grab_focus()
			Globals.current_dropped = ""
		ins.set_data(metadata)
		ins.set_meta("file_name", file)

func reload_beatmaps() -> void:
	var dir = DirAccess.open(path)
	var files = dir.get_files()
	var exclude = []
	for child in levels_container.get_children():
		var file_name = child.get_meta("file_name", "")
		if not file_name in files:
			child.queue_free()
			continue
		exclude.append(file_name)
	load_beatmaps(exclude)

func _on_beatmap_selected(mdata: Dictionary, data: Dictionary, beatmap_path: String) -> void:
	current_beatmap_path = beatmap_path
	level_info.set_metadata(mdata)
	if not Settings.misc.level_music_in_selection: return
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

func _on_refresh_timer_timeout() -> void:
	reload_beatmaps()

func _on_modifiers_pressed() -> void:
	modifiers_popup.popup()

func _on_manage_pressed() -> void:
	manage_popup.popup()

func _on_manage_remove_beatmap() -> void:
	var err = DirAccess.remove_absolute(current_beatmap_path)
	if err != OK:
		print(error_string(err))
		Toast.error("Error removing BeatMap", "try again later")
	else:
		Toast.show("BeatMap removed", "BeatMap removed successfully")

func _on_manage_share() -> void:
	share.share_file(current_beatmap_path, "application/octet-stream", "Check my Rhycut BeatMap", "", "")
