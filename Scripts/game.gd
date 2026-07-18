extends Node2D

@export var note_scene: PackedScene
@export var bomb_scene: PackedScene
@export var beatmap: BeatMap
@export var max_health: int = 4000
@export var editor = false

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var rank_label: Label = %rank_label
@onready var time_label: Label = %time_label
@onready var accuracy_label: Label = %accuracy_label
@onready var notes_container: Node2D = %notes_container
@onready var cut: Sprite2D = %cut
@onready var health_bar: ProgressBar = %health_bar
@onready var end_screen: CanvasLayer = %end_screen
@onready var rhythm_notifier: RhythmNotifier = %RhythmNotifier
@onready var song_name: ScrollLabel = %song_name
@onready var song_author: ScrollLabel = %song_author
@onready var song_website: ScrollLabel = %song_website
@onready var song_info: VBoxContainer = %song_info
@onready var fps: Label = %fps

var notes: Array[NoteResource] = []
var accuracy: float = 100.0
var health: int = 4000
var running = true

func _ready() -> void:
	if not beatmap:
		beatmap = GameState.current_beatmap
	rhythm_notifier.bpm = beatmap.bpm
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health
	audio_stream_player.stream = beatmap.audio
	song_name.text = beatmap.metadata.song_name
	song_author.text = "by " + beatmap.metadata.song_author
	if beatmap.metadata.has("song_website"):
		song_website.text = beatmap.metadata.song_website
	else:
		song_website.hide()
	if not beatmap.updated:
		beatmap.update_all_notes()
	notes = beatmap.notes.duplicate()
	if GameState.is_modifier_active("x2"):
		audio_stream_player.pitch_scale = 2.0
		var idx = AudioServer.get_bus_index("Music")
		var pitch_effect = AudioServer.get_bus_effect(idx, 0) as AudioEffectPitchShift
		pitch_effect.pitch_scale = 0.5
	audio_stream_player.play(GameState.current_song_position)
	song_info.show()
	if not Settings.misc.song_info:
		song_info.hide()
	if not Settings.misc.fps_counter:
		fps.hide()

func _physics_process(delta: float) -> void:
	queue_redraw()

func _process(delta: float) -> void:
	if not running:
		return
	accuracy_label.text = str(accuracy).pad_decimals(1) + "%"
	GameState.current_song_position = audio_stream_player.get_playback_position()
	var pos = audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	for note in notes:
		var note_spawn_time = note.time - note.time_to_peak - 1.5
		if pos >= note_spawn_time:
			if note.type == 0:
				var ins = note_scene.instantiate()
				ins.resource = note
				notes_container.add_child(ins)
				ins.cut_time.connect(_on_cut_time)
				ins.miss.connect(_on_fail)
				ins.cuts = cut
				notes.erase(note)
			else:
				var ins = bomb_scene.instantiate()
				ins.resource = note
				notes_container.add_child(ins)
				ins.explode.connect(_on_bomb_explosion)
				ins.cuts = cut
				notes.erase(note)
	health_bar.value = health
	if notes.size() <= 0 and total_notes == beatmap.notes.filter(func(val): return val.type == 0).size():
		await get_tree().create_timer(1.5).timeout
		finish_game()

var perfect = 0
var great = 0
var good = 0
var bad = 0
var miss = 0
var total_notes = 0
var accumulated = 0

func _on_cut_time(time: float) -> void:
	total_notes += 1
	var ms = time * 1000
	rank_label.show()
	time_label.show()
	time_label.text = "%d ms" % ms
	accumulated += clamp(remap(abs(ms), 50, 200, 100, 0), 0, 100)
	if ms >= -50 and ms <= 50:
		rank_label.text = "PERFECT"
		rank_label.label_settings.font_color = Color("ffe478")
		perfect += 1
		health += remap(abs(ms), 50, 0, 0, 200)
	elif ms >= -100 and ms <= 100:
		rank_label.text = "GREAT"
		rank_label.label_settings.font_color = Color("4da6ff")
		great += 1
		health -= abs(ms)
	elif ms >= -150 and ms <= 150:
		rank_label.text = "GOOD"
		rank_label.label_settings.font_color = Color("8fde5d")
		good += 1
		health -= abs(ms)
	elif ms >= -200 and ms <= 200:
		rank_label.text = "BAD"
		rank_label.label_settings.font_color = Color("b0305c")
		bad += 1
		health -= abs(ms)
	elif ms < -200 or ms > 200:
		rank_label.text = "MISS"
		rank_label.label_settings.font_color = Color("606070")
		miss += 1
		health -= abs(ms)
	accuracy = accumulated / total_notes

func _on_fail() -> void:
	total_notes += 1
	rank_label.show()
	time_label.hide()
	rank_label.text = "MISS"
	rank_label.label_settings.font_color = Color("606070")
	miss += 1
	health -= 1000
	if total_notes != 0:
		accuracy = accumulated / total_notes

func _on_bomb_explosion() -> void:
	health -= max_health / 4

func finish_game() -> void:
	if editor:
		get_parent().hide()
		queue_free()
		return
	var data = {
		"perfect": perfect,
		"great": great,
		"good": good,
		"bad": bad,
		"miss": miss,
		"accuracy": accuracy,
		"loss": health <= 0
	}
	end_screen.show_data(data)
	running = false

func _on_rhythm_notifier_beat(current_beat: int) -> void:
	if Settings.video.cam_pulse_to_bpm:
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
		$Camera2D.zoom = Vector2(1.01, 1.01)
		tween.tween_property($Camera2D, "zoom", Vector2.ONE, 0.2)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var distance = Vector2.ZERO.distance_to(event.relative)
			if distance < 3:
				return
			var space_state = get_world_2d().direct_space_state
			var ray_result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(event.global_position - event.relative, event.global_position))
			if not ray_result:
				return
			if ray_result.collider is Item:
				ray_result.collider.cut()

var points = []

func _draw() -> void:
	var max_points = 8
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		points.append(get_global_mouse_position())
		var idx = 0
		for point in points:
			if idx + 1 >= points.size():
				break
			var width = remap(idx, 0, 8, 0.5, 3.0)
			var opacity = remap(idx, 0, 8, 1, 255)
			draw_line(points[idx], points[idx + 1], Color("c2c2d1%02x" % opacity), width)
			idx += 1
		if points.size() > max_points:
			points.pop_front()
	else:
		points.clear()

func _on_health_bar_value_changed(value: float) -> void:
	if value == 0:
		finish_game()

func _on_fps_timer_timeout() -> void:
	fps.text = str(floori(1 / get_process_delta_time())) + " fps"
