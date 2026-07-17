extends Node

var audio = {
	"Master": 1.0,
	"Music": 1.0,
	"SFX": 0.5
}

var video = {
	"cam_bpm": true,
	"sprite_scaling": true,
	"fullscreen": false
}

var misc = {
	"song_info": false
}

func _ready() -> void:
	load_settings()
	apply_settings()
	if OS.get_name() == "Android" and not video.fullscreen:
		video.fullscreen = true
		save_settings()
		apply_settings()

func save_settings() -> void:
	var cfg = ConfigFile.new()
	for k in audio:
		cfg.set_value("Audio", k, audio[k])
	for k in video:
		cfg.set_value("Video", k, video[k])
	for k in misc:
		cfg.set_value("Misc", k, misc[k])
	cfg.save("user://settings/settings.cfg")

func load_settings() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load("user://settings/settings.cfg")
	if err != OK:
		return
	for s in cfg.get_sections():
		for k in cfg.get_section_keys(s):
			get(s.to_lower())[k] = cfg.get_value(s, k)

func apply_settings() -> void:
	for k in audio:
		var bus_idx = AudioServer.get_bus_index(k)
		AudioServer.set_bus_volume_linear(bus_idx, audio[k])
	if video.sprite_scaling:
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	elif not video.sprite_scaling:
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	if video.fullscreen:
		get_window().mode = Window.MODE_FULLSCREEN
	elif not video.fullscreen:
		get_window().mode = Window.MODE_WINDOWED
