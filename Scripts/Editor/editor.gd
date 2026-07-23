extends Node2D

@export var note_scene: PackedScene
@export var bomb_scene: PackedScene
@export var beatmap: BeatMap

@onready var song_player: AudioStreamPlayer = %song_player
@onready var editor_hud: EditorHUD = %editor_hud
@onready var notes_container: Node2D = %notes_container
@onready var preview: Sprite2D = %preview
@onready var rhythm: RhythmNotifier = %rhythm
@onready var preview_player: AudioStreamPlayer = %preview_player

var notes: Array[NoteResource] = []
var mode = "selection"

func _process(delta: float) -> void:
	mode = editor_hud.mode
	editor_hud.beatmap = beatmap
	preview.global_position = get_global_mouse_position()
	if mode == "pencil":
		preview.texture = preload("uid://obhvqrxyyqks")
		preview.show()
	elif mode == "bomb":
		preview.texture = preload("uid://bu0tafg70lqwb")
		preview.show()
	else:
		preview.hide()
	if not song_player.stream_paused:
		preview.hide()
		AudioHelper.current_playback_position = song_player.get_playback_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and song_player.stream_paused:
			if mode == "pencil":
				add_note()
			elif mode == "bomb":
				add_bomb()

func add_note() -> void:
	var audio_time = AudioHelper.time
	var pos = get_global_mouse_position()
	var note = NoteResource.new(0, audio_time, pos)
	beatmap.notes.append(note)
	beatmap.update_last_note()
	respawn_notes()

func add_bomb() -> void:
	var audio_time = AudioHelper.time
	var pos = get_global_mouse_position()
	var note = NoteResource.new(1, audio_time, pos)
	beatmap.notes.append(note)
	beatmap.update_last_note()
	respawn_notes()

func respawn_notes() -> void:
	for child in notes_container.get_children():
		child.queue_free()
	notes = beatmap.notes.duplicate()
	spawn_notes()

func spawn_notes() -> void:
	var idx = 0
	for note in notes:
		var ins
		if note.type == 0:
			ins = note_scene.instantiate()
		else:
			ins = bomb_scene.instantiate()
		if not ins: continue
		ins.resource = note
		ins.editor = true
		ins.paused = song_player.stream_paused
		ins.mouse_entered.connect(_on_note_mouse_entered.bind(ins))
		ins.mouse_exited.connect(_on_note_mouse_exited.bind(ins))
		ins.input_event.connect(_on_note_input_event.bind(ins))
		notes_container.add_child(ins)
		ins.set_meta("index", idx)
		idx += 1

func _on_note_mouse_entered(note: Item) -> void:
	if not song_player.stream_paused:
		return
	if mode == "selection":
		(note.sprite.material as ShaderMaterial).set_shader_parameter("color", Color("ffffeb"))
		(note.sprite.material as ShaderMaterial).set_shader_parameter("quantity", 0.7)
	elif mode == "eraser":
		(note.sprite.material as ShaderMaterial).set_shader_parameter("color", Color("b0305c"))
		(note.sprite.material as ShaderMaterial).set_shader_parameter("quantity", 0.7)

func _on_note_mouse_exited(note: Item) -> void:
	(note.sprite.material as ShaderMaterial).set_shader_parameter("quantity", 0.0)

func _on_note_input_event(viewport: Node, event: InputEvent, shape_idx: int, note: Item) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and song_player.stream_paused:
			if mode == "selection":
				AudioHelper.time = note.resource.time
			elif mode == "eraser":
				var idx = note.get_meta("index")
				beatmap.notes.remove_at(idx)
				respawn_notes()

func _on_editor_hud_song_position_changed(new_position: float) -> void:
	if not song_player.stream:
		return
	var song_duration = song_player.stream.get_length()
	AudioHelper.time = song_duration * new_position
	song_player.seek(song_duration * new_position)

func _on_editor_hud_pause_music() -> void:
	AudioHelper.pause_game()
	song_player.stream_paused = true
	for note in notes_container.get_children():
		note.paused = true

func _on_editor_hud_play_music() -> void:
	AudioHelper.start_game()
	var pos = AudioHelper.time
	song_player.play(max(0, pos))
	song_player.stream_paused = false
	for note in notes_container.get_children():
		note.paused = false

func _on_editor_hud_beat_back() -> void:
	song_player.seek(song_player.get_playback_position() - rhythm.beat_length)
	if song_player.stream_paused:
		AudioHelper.time -= rhythm.beat_length / 4
		AudioHelper.time = max(AudioHelper.time, 0)

func _on_editor_hud_beat_forward() -> void:
	song_player.seek(song_player.get_playback_position() + rhythm.beat_length)
	if song_player.stream_paused:
		AudioHelper.time += rhythm.beat_length / 4
		AudioHelper.time = min(AudioHelper.time, song_player.stream.get_length())

func _on_editor_hud_play_preview() -> void:
	preview_player.play(AudioHelper.time)

func _on_editor_hud_pause_preview() -> void:
	preview_player.stop()

func _on_editor_hud_beatmap_loaded(bm: BeatMap) -> void:
	_on_editor_hud_audio_loaded(bm.audio)
	beatmap = bm
	beatmap.update_all_notes()
	respawn_notes()

func _on_editor_hud_audio_loaded(audio: AudioStream) -> void:
	beatmap.audio = audio
	song_player.stream = audio
	preview_player.stream = audio
	editor_hud.change_duration_label(song_player.stream.get_length())
	editor_hud.change_position_bar_step(rhythm.beat_length / song_player.stream.get_length() / 4)
	GameState.song_length = audio.get_length()
	AudioHelper.start_game()
	AudioHelper.stop_game()

func _on_editor_hud_bpm_changed(bpm: float) -> void:
	rhythm.bpm = bpm
