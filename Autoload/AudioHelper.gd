extends Node

var game_running = false
var current_playback_position = 0.0
var last_playback_position = 0.0
var tick_at_last_audio_change = 0

var time = 0.0
var latency = 0.0

func _ready() -> void:
	latency = AudioServer.get_output_latency()

func _process(delta: float) -> void:
	if not game_running:
		return
	if current_playback_position != last_playback_position:
		time = current_playback_position - latency
		last_playback_position = current_playback_position
		tick_at_last_audio_change = Time.get_ticks_usec()
	else:
		var time_since_audio_change = (Time.get_ticks_usec() - tick_at_last_audio_change) / 1000000.0
		time = last_playback_position + time_since_audio_change - latency

func start_game() -> void:
	game_running = true
	tick_at_last_audio_change = Time.get_ticks_usec()
	current_playback_position = 0.0
	last_playback_position = 0.0

func pause_game() -> void:
	game_running = false
	current_playback_position = 0.0
	last_playback_position = 0.0

func stop_game() -> void:
	game_running = false
	current_playback_position = 0.0
	last_playback_position = 0.0
	time = 0.0
	tick_at_last_audio_change = 0.0

func create_stream_from_bytes(bytes: PackedByteArray) -> AudioStream:
	if bytes.is_empty(): 
		return null
	var header_4 = bytes.slice(0, 4).get_string_from_ascii()
	if header_4 == "OggS":
		return AudioStreamOggVorbis.load_from_buffer(bytes)
	if header_4 == "RIFF":
		return AudioStreamWAV.load_from_buffer(bytes)
	var header_3 = bytes.slice(0, 3).get_string_from_ascii()
	if header_3 == "ID3" or (bytes[0] == 0xFF and (bytes[1] & 0xF0) == 0xF0):
		return AudioStreamMP3.load_from_buffer(bytes)
	return null
