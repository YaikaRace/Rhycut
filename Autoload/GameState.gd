extends Node

var current_beatmap: BeatMap
var current_song_position = 0.0
var song_length = 0.0

func reset_state() -> void:
	current_beatmap = null
	current_song_position = 0.0
	song_length = 0.0

func reset_level() -> void:
	current_song_position = 0.0
	song_length = 0.0
