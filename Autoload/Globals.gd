extends Node

var note_gravity = 5.0
var current_dropped = ""

func _ready() -> void:
	get_tree().quit_on_go_back = false
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("settings"):
		dir.make_dir("settings")
	if not dir.dir_exists("beatmaps"):
		dir.make_dir("beatmaps")
		copy_starter_beatmaps_first_time()
	copy_starter_beatmaps()
	get_tree().get_root().files_dropped.connect(_on_files_dropped)

func copy_starter_beatmaps_first_time() -> void:
	var dir = DirAccess.open("res://Starter Beatmaps")
	for file in dir.get_files():
		dir.copy("res://Starter Beatmaps".path_join(file), "user://beatmaps/".path_join(file))

func restore_starter_beatmaps() -> void:
	var dir = DirAccess.open("res://Starter Beatmaps")
	for file in dir.get_files():
		if FileAccess.file_exists("user://beatmaps/".path_join(file)):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://beatmaps/".path_join(file)))
		dir.copy("res://Starter Beatmaps".path_join(file), "user://beatmaps/".path_join(file))

func copy_starter_beatmaps() -> void:
	var dir = DirAccess.open("res://Starter Beatmaps")
	for file in dir.get_files():
		if FileAccess.file_exists("user://beatmaps/".path_join(file)):
			var f = FileAccess.open("res://Starter Beatmaps".path_join(file), FileAccess.READ)
			var metadata = f.get_var()
			f.close()
			f = FileAccess.open("user://beatmaps/".path_join(file), FileAccess.READ)
			var old_metadata = f.get_var()
			f.close()
			if not old_metadata.has("map_version"):
				var e = dir.copy("res://Starter Beatmaps".path_join(file), "user://beatmaps/".path_join(file))
			if metadata.map_version != old_metadata.map_version:
				dir.copy("res://Starter Beatmaps".path_join(file), "user://beatmaps/".path_join(file))

func _on_files_dropped(files: PackedStringArray) -> void:
	if not get_tree().current_scene.name in ["main_menu", "settings", "level_selection"]:
		return
	var file = files[0]
	if file.get_extension() != "rcbm":
		return
	var f = DirAccess.open(file.get_base_dir())
	f.copy(file, "user://beatmaps/" + file.get_file())
	current_dropped = file.get_file()
	get_tree().change_scene_to_file("res://Scenes/Menus/Level Selection/level_selection.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		Input.action_press("ui_cancel")
		Input.action_release("ui_cancel")
		Input.action_press("pause_game")
		Input.action_release("pause_game")
