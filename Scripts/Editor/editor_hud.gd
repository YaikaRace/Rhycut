class_name EditorHUD extends CanvasLayer

signal song_position_changed(new_position: float)
signal play_music
signal pause_music
signal beat_back
signal beat_forward
signal play_preview
signal pause_preview
signal beatmap_loaded(bm: BeatMap)
signal audio_loaded(audio: AudioStream)
signal bpm_changed(bpm: float)

@onready var song_position_bar: HSlider = %song_position_bar
@onready var current_position_label: Label = %current_position_label
@onready var duration_label: Label = %duration_label
@onready var play_pause: TextureButton = %play_pause
@onready var mode_buttons: HBoxContainer = %mode_buttons
@onready var test_window: Window = %test_window
@onready var save_dialog: FileDialog = %save_dialog
@onready var load_dialog: FileDialog = %load_dialog
@onready var load_music_file_dialog: FileDialog = %load_music_file_dialog
@onready var test_level: Button = %test_level
@onready var save_level: Button = %save_level
@onready var metadata_form: ConfirmationDialog = %metadata_form
@onready var bpm_box: SpinBox = %bpm_box
@onready var load_music_html5: HTML5FileDialog = %load_music_html5
@onready var load_level_html5: HTML5FileDialog = %load_level_html5

var is_changing_song_position = false

var mode = "selection"
var paused = true
var beatmap: BeatMap
var current_metadata: Dictionary = {}
var working_path: String = ""

func _ready() -> void:
	for button in mode_buttons.get_children():
		button.toggled.connect(_on_mode_button_toggled.bind(button))

func _process(delta: float) -> void:
	song_seek(GameState.current_song_position / GameState.song_length)
	change_position_label(GameState.current_song_position)
	hide_buttons()

func hide_buttons() -> void:
	if paused:
		mode_buttons.show()
		return
	mode_buttons.hide()

func change_position_label(seconds: float) -> void:
	var formatted = format_time(seconds)
	current_position_label.text = formatted

func change_duration_label(seconds: float) -> void:
	var formatted = format_time(seconds)
	duration_label.text = formatted

func change_position_bar_step(step: float) -> void:
	song_position_bar.step = step

func format_time(seconds: float) -> String:
	var sec = floori(seconds) % 60
	var minutes = floor(seconds / 60)
	var hours = floor(minutes / 60)
	var format = "%02d:%02d" % [minutes, sec]
	if hours > 0:
		format = "%02d:%02d:%02d" % [hours, minutes, sec]
	return format

func song_seek(position: float) -> void:
	if is_changing_song_position: return
	song_position_bar.value = position

func save_file(path: String) -> void:
	if not OS.has_feature("web"):
		working_path = path
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_var(beatmap.metadata)
	f.store_var(beatmap.get_save_data())
	f.close()
	if OS.has_feature("web"):
		var file = FileAccess.get_file_as_bytes(path)
		var base64 = Marshalls.raw_to_base64(file)
		var js_code = """
		(function(base64, filename) {
			const byteCharacters = atob(base64);
			const byteNumbers = new Array(byteCharacters.length);
			for (let i = 0; i < byteCharacters.length; i++) {
				byteNumbers[i] = byteCharacters.charCodeAt(i);
			}
			const byteArray = new Uint8Array(byteNumbers);
			const blob = new Blob([byteArray], {type: 'application/octet-stream'});
			const url = URL.createObjectURL(blob);
			const a = document.createElement('a');
			a.href = url;
			a.download = filename;
			document.body.appendChild(a);
			a.click();
			document.body.removeChild(a);
			URL.revokeObjectURL(url);
		})("%s", "%s");
		""" % [base64, "beatmap.rcbm"]
		JavaScriptBridge.eval(js_code)

func _on_mode_button_toggled(toggled_on: bool, button: Button) -> void:
	if toggled_on:
		mode = button.name

func _on_song_position_bar_drag_ended(value_changed: bool) -> void:
	is_changing_song_position = false
	if not value_changed:
		return
	song_position_changed.emit(song_position_bar.value)

func _on_song_position_bar_drag_started() -> void:
	is_changing_song_position = true

func _on_play_pause_toggled(toggled_on: bool) -> void:
	paused = toggled_on
	if toggled_on:
		play_pause.get_child(0).hide()
		play_pause.get_child(1).show()
		pause_music.emit()
		song_position_bar.value = song_position_bar.value
		GameState.current_song_position = song_position_bar.value * GameState.song_length
		return
	play_pause.get_child(1).hide()
	play_pause.get_child(0).show()
	play_music.emit()

func _on_beat_back_pressed() -> void:
	beat_back.emit()

func _on_beat_forward_pressed() -> void:
	beat_forward.emit()

func _on_play_music_toggled(toggled_on: bool) -> void:
	if toggled_on:
		play_preview.emit()
		return
	pause_preview.emit()

func _on_test_level_pressed() -> void:
	var level_scene = preload("res://Scenes/game.tscn")
	var level_ins = level_scene.instantiate()
	level_ins.beatmap = beatmap
	level_ins.editor = true
	test_window.add_child(level_ins)
	test_window.move_child(level_ins, 0)
	test_window.popup_centered()
	play_pause.set_pressed(true)

func _on_stop_test_pressed() -> void:
	test_window.get_child(0).queue_free()
	test_window.hide()
	song_position_bar.value = song_position_bar.value
	GameState.current_song_position = song_position_bar.value * GameState.song_length

func _on_save_level_pressed() -> void:
	if not current_metadata:
		metadata_form.popup_centered()
	elif working_path:
		if OS.has_feature("web"):
			save_file("user://temp.rcbm")
		else:
			save_file(working_path)

func _on_save_dialog_file_selected(path: String) -> void:
	save_file(path)

func _on_open_level_pressed() -> void:
	if OS.has_feature("web"):
		return
	load_dialog.popup_centered()

func _on_load_dialog_file_selected(path: String) -> void:
	var f = FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		return
	var metadata = f.get_var()
	var data = f.get_var()
	var bm = BeatMap.new()
	var err = bm.set_metadata(metadata)
	if err != OK:
		return
	print(data.audio_type)
	bpm_box.value = metadata.bpm
	metadata_form.load_data(metadata)
	err = bm.parse_data(data)
	if err != OK:
		return
	beatmap_loaded.emit(bm)
	f.close()

func _on_open_music_file_pressed() -> void:
	if OS.has_feature("web"):
		load_music_html5.show()
		return
	load_music_file_dialog.popup_centered()

func _on_load_music_file_dialog_file_selected(path: String) -> void:
	var extension = path.get_extension()
	beatmap.audio_type = extension
	if extension == "mp3":
		var stream = AudioStreamMP3.load_from_file(path)
		audio_loaded.emit(stream)
	elif extension == "ogg":
		var stream = AudioStreamOggVorbis.load_from_file(path)
		audio_loaded.emit(stream)
	elif extension == "wav":
		var stream = AudioStreamWAV.load_from_file(path)
		audio_loaded.emit(stream)

func _on_save_data_finished(data: Dictionary) -> void:
	data["bpm"] = beatmap.bpm
	current_metadata = data
	beatmap.metadata = data
	if OS.has_feature("web"):
		save_file("user://temp.rcbm")
		return
	save_dialog.popup_centered()

func _on_save_dialog_canceled() -> void:
	current_metadata = {}
	beatmap.metadata = {}

func _on_bpm_box_value_changed(value: float) -> void:
	beatmap.bpm = value
	bpm_changed.emit(value)

func _on_html_5_file_dialog_file_selected(file: HTML5FileHandle) -> void:
	var buffer = await file.as_buffer()
	var stream = AudioHelper.create_stream_from_bytes(buffer)
	if not stream:
		return
	audio_loaded.emit(stream)

# TODO: implement level loading in html5
func _on_load_level_html_5_file_selected(file: HTML5FileHandle) -> void:
	pass
