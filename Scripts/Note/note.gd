class_name Note extends Item

@onready var sfx: AudioStreamPlayer = %sfx

func cut() -> void:
	var current_time = GameState.current_song_position + AudioServer.get_time_since_last_mix()
	printt(current_time, resource.time)
	cut_time.emit(current_time - resource.time)
	if current_time >= resource.time + 0.25 or current_time <= resource.time - 0.25:
		print("Bad - %.2fs" % (current_time - resource.time))
	elif current_time >= resource.time + 0.12 or current_time <= resource.time - 0.12:
		print("Good - %.2fs" % (current_time - resource.time))
	elif current_time >= resource.time + 0.0 or current_time <= resource.time - 0.0:
		print("Perfect - %.2fs" % (current_time - resource.time))
	generate_particles()
	_add_sfx()
	cuts.global_position = global_position
	cuts.play()
	cuts.global_rotation = global_rotation
	queue_free()

func generate_particles() -> void:
	var ins = particles.instantiate()
	get_parent().add_child(ins)
	ins.global_position = global_position
	ins.z_index = z_index - 1
	ins.start(sprite.global_rotation_degrees)

func screen_exited() -> void:
	if editor: return
	if GameState.current_song_position > resource.time:
		miss.emit()

func _add_sfx() -> void:
	var node = get_tree().get_root().get_node_or_null("wood_sfx")
	if node:
		return
	var c = sfx.duplicate()
	c.name = "wood_sfx"
	c.finished.connect(c.queue_free)
	get_tree().get_root().add_child(c)
	c.play()
