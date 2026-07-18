extends AcceptDialog

signal remove_beatmap

@onready var open_folder: Button = %open_folder
@onready var import_dialog: FileDialog = %import_dialog

func _ready() -> void:
	if OS.get_name() == "Android":
		open_folder.hide()

func _on_open_folder_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://beatmaps"))

func _on_import_file_pressed() -> void:
	import_dialog.popup()

func _on_remove_beatmap_pressed() -> void:
	remove_beatmap.emit()

func _on_import_dialog_file_selected(path: String) -> void:
	var err = DirAccess.copy_absolute(path, ProjectSettings.globalize_path("user://beatmaps".path_join(path.get_file())))
	if err != OK:
		print(error_string(err))
		Toast.error("Error importing BeatMap", "try again later")
	else:
		Toast.show("BeatMap Imported", "BeatMap imported successfully")
