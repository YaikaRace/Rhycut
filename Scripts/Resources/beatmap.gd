class_name BeatMap extends Resource

@export var notes: Array[NoteResource] = []
@export var audio: AudioStream
@export var audio_type = ""
@export var bpm = 60.0

var metadata: Dictionary = {}

var updated = false

func update_all_notes() -> void:
	updated = true
	for note in notes:
		apply_initial_velocity(note)

func update_last_note() -> void:
	updated = true
	apply_initial_velocity(notes[-1])

func apply_initial_velocity(note: NoteResource) -> void:
	randomize()
	var initial_pos = Vector2(randi_range(0, 320), 215)
	var final_pos = note.spawn_pos
	var gravity = Globals.note_gravity * 60
	var distance = final_pos - initial_pos
	#print(distance)
	var velocity = Vector2.ZERO
	velocity.y = -sqrt(2 * gravity * abs(distance.y))
	var time = abs(velocity.y / gravity)
	velocity.x = distance.x / time
	note.initial_velocity = velocity
	note.initial_position = initial_pos
	note.initial_angular_velocity = [randi_range(180, 360), randi_range(-360, -180)].pick_random()
	note.time_to_peak = time

func get_save_data() -> Dictionary:
	var data = {
		"audio": audio.data,
		"audio_type": audio_type,
		"notes": []
		}
	for note in notes:
		var ndata = {
			type = note.type,
			time = note.time,
			spawn_pos = note.spawn_pos
		}
		data.notes.append(ndata)
	return data

func parse_data(data: Dictionary) -> Error:
	var err = validate_data(data)
	if err != OK:
		return err
	if data.audio_type == "mp3":
		audio = AudioStreamMP3.load_from_buffer(data.audio)
	elif data.audio_type == "ogg":
		audio = AudioStreamOggVorbis.load_from_buffer(data.audio)
	elif data.audio_type == "wav":
		audio = AudioStreamWAV.load_from_buffer(data.audio)
	audio_type = data.audio_type
	for note in data.notes:
		var n = NoteResource.new(note.type, note.time, note.spawn_pos)
		notes.append(n)
	return Error.OK

func set_metadata(data: Dictionary) -> Error:
	var err = validate_metadata(data)
	if err != OK:
		return err
	bpm = data.bpm
	metadata = data
	return Error.OK

func validate_metadata(data: Dictionary) -> Error:
	if not data.has("version"):
		return Error.ERR_INVALID_DATA
	if data.version != Constants.BEATMAP_VERSION:
		return Error.ERR_INVALID_PARAMETER
	return Error.OK

func validate_data(data: Dictionary) -> Error:
	if not data.has("notes"):
		return Error.ERR_INVALID_DATA
	if not data.has("audio_type"):
		return Error.ERR_INVALID_DATA
	return Error.OK
