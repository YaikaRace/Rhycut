extends Node2D

@onready var cut: Sprite2D = %cut
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var notes_container: Node2D = %notes_container

const NOTE = preload("uid://02leyw6bf53e")

var beatmap = BeatMap.new()

var offset = 0.0
var audio_length = 0.0
var time = 0.0
var loops = 0
var last_pos = 0.0
var interval = 2.0
var next_note_time = 2.0

func _ready() -> void:
	get_window().window_input.connect(window_input)
	audio_length = audio_stream_player.stream.get_length()
	GameState.song_length = audio_length
	audio_stream_player.play()
	generate_note(2)

func miss(note: Note) -> void:
	note.queue_free()

func _process(delta: float) -> void:
	queue_redraw()
	var pos = audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix() + offset
	var current = audio_stream_player.get_playback_position()
	if current < last_pos:
		loops += 1
	last_pos = current
	time = loops * audio_length + pos
	GameState.current_song_position = time
	while time >= next_note_time:
		next_note_time += interval
		generate_note(next_note_time)

func generate_note(time) -> Note:
	var pos = Vector2(160, 60)
	var ins: Item = NOTE.instantiate()
	ins.resource = NoteResource.new(0, time, pos)
	ins.cuts = cut
	beatmap.apply_initial_velocity(ins.resource)
	ins.cut_time.connect(_on_note_cut_time.bind(ins))
	ins.miss.connect(miss.bind(ins))
	notes_container.add_child(ins)
	return ins

func _on_note_cut_time(time: float, note: Note) -> void:
	var label = Label.new()
	label.theme = preload("uid://c08u4scde3g3e")
	label.text = str(floori(time * 1000)) + "ms"
	add_child(label)
	label.scale = Vector2.ZERO
	label.global_position = note.global_position
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(label, "scale", Vector2.ONE, 0.3)
	await get_tree().create_timer(1).timeout
	tween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(label, "scale", Vector2.ZERO, 0.3)
	await tween.finished
	label.queue_free()

func window_input(event: InputEvent) -> void:
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
		points.append(get_window().get_mouse_position())
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

func _on_audio_stream_player_finished() -> void:
	audio_stream_player.play()
