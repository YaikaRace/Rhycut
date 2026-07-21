extends ConfirmationDialog

signal finished(data: Dictionary)

@onready var name_edit: LineEdit = %name_edit
@onready var author_edit: LineEdit = %author_edit
@onready var music_edit: LineEdit = %music_edit
@onready var music_author_edit: LineEdit = %music_author_edit
@onready var song_website_edit: LineEdit = %song_website_edit
@onready var icon_texture: TextureRect = %icon_texture
@onready var icon_select: Button = %icon_select
@onready var image_select_dialog: FileDialog = %image_select_dialog
@onready var warning: Label = %warning
@onready var map_version_edit: LineEdit = %map_version_edit

var icon: Image = preload("res://Assets/Sprites/music-note.png").get_image()

func _ready() -> void:
	hide()
	get_ok_button().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	get_cancel_button().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func load_data(data: Dictionary) -> void:
	name_edit.text = data.name
	author_edit.text = data.author
	music_edit.text = data.song_name
	map_version_edit.text = data.map_version
	music_author_edit.text = data.song_author
	song_website_edit.text = data.song_website
	icon = Image.new()
	icon.data = data.icon
	icon_texture.texture = ImageTexture.create_from_image(icon)

func _on_icon_select_pressed() -> void:
	image_select_dialog.popup_centered()

func _on_image_select_dialog_file_selected(path: String) -> void:
	if path.get_extension() in ["png", "jpg", "jpeg", "svg"]:
		icon = Image.load_from_file(path)
		icon_texture.texture = ImageTexture.create_from_image(icon)

func _on_confirmed() -> void:
	var checked = check_fields()
	if not checked:
		warning.show()
		popup()
		return
	var data = {
		"version": Constants.BEATMAP_VERSION,
		"name": name_edit.text,
		"author": author_edit.text,
		"map_version": map_version_edit.text,
		"song_name": music_edit.text,
		"song_author": music_author_edit.text,
		"song_website": song_website_edit.text,
		"icon": icon.data
	}
	finished.emit(data)

func check_fields() -> bool:
	if name_edit.text and author_edit.text and music_edit.text and music_author_edit.text:
		return true
	return false
