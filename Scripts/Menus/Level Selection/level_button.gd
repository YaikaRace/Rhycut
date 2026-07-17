extends PanelContainer

signal pressed(data: Dictionary)

@export var normal_texture: Texture2D
@export var focus_texture: Texture2D

@onready var level_name: ScrollLabel = %level_name
@onready var song_name: ScrollLabel = %song_name
@onready var icon: TextureRect = %icon

var level_path: String = ""
var focused = false

var metadata: Dictionary

func set_data(data: Dictionary) -> void:
	metadata = data
	level_name.text = "%s by %s" % [data.name, data.author]
	song_name.text = '"%s" by %s' % [data.song_name, data.song_author]
	var img = Image.new()
	img.data = data.icon
	icon.texture = ImageTexture.create_from_image(img)

func change_texture(new_texture: Texture2D) -> void:
	var style_box: StyleBoxTexture = get_theme_stylebox("panel")
	style_box.texture = new_texture

func _on_focus_entered() -> void:
	change_texture(focus_texture)
	level_name.color = Color("272736")
	song_name.color = Color("606070")

func _on_focus_exited() -> void:
	change_texture(normal_texture)
	level_name.color = Color("ffffeb")
	song_name.color = Color("c2c2d1")
	focused = false

func _on_mouse_entered() -> void:
	if has_focus(): return
	change_texture(focus_texture)
	level_name.color = Color("272736")
	song_name.color = Color("606070")

func _on_mouse_exited() -> void:
	if has_focus(): return
	change_texture(normal_texture)
	level_name.color = Color("ffffeb")
	song_name.color = Color("c2c2d1")

func _on_gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if level_path and has_focus():
			open_level(level_path)
			return
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if level_path and focused:
				open_level(level_path)
				return
			pressed.emit(metadata)
			focused = true

func open_level(path: String) -> void:
	var f = FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		return
	var mdata = f.get_var()
	var data = f.get_var()
	f.close()
	var beatmap = BeatMap.new()
	var err = beatmap.set_metadata(mdata)
	if err != OK:
		return
	err = beatmap.parse_data(data)
	if err != OK:
		return
	GameState.current_beatmap = beatmap
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
