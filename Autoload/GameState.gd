extends Node

var current_beatmap: BeatMap
var current_song_position = 0.0
var song_length = 0.0

var modifiers = []

func reset_state() -> void:
	current_beatmap = null
	reset_level()

func reset_level() -> void:
	current_song_position = 0.0
	song_length = 0.0

func is_modifier_active(mod: String) -> bool:
	return mod in modifiers
