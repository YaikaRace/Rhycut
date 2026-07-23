extends Node

var audio = {
	"Master": 1.0,
	"Music": 1.0,
	"SFX": 0.5
}

var video = {
	"cam_pulse_to_bpm": true,
	"sprite_scaling": true,
	"v_sync": true,
}

var video_pc_only = {
	"fullscreen": false
}

var misc = {
	"fps_counter": false,
	"song_info": false,
	"level_music_in_selection": true
}

var calibration = {
	"offset": 0.0
}

func _ready() -> void:
	merge_settings()
	load_settings()
	apply_settings()

func merge_settings() -> void:
	if OS.get_name() != "Android":
		video.merge(video_pc_only)

func save_settings() -> void:
	var cfg = ConfigFile.new()
	for k in audio:
		cfg.set_value("Audio", k, audio[k])
	for k in video:
		cfg.set_value("Video", k, video[k])
	for k in misc:
		cfg.set_value("Misc", k, misc[k])
	for k in calibration:
		cfg.set_value("Calibration", k, calibration[k])
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
	if video.v_sync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	elif not video.v_sync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if OS.get_name() == "Android":
		get_window().mode = Window.MODE_FULLSCREEN
		return
	if video.fullscreen:
		get_window().mode = Window.MODE_FULLSCREEN
	elif not video.fullscreen:
		get_window().mode = Window.MODE_WINDOWED
