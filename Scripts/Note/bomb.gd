class_name Bomb extends Item

signal explode

@onready var sfx: AudioStreamPlayer = $sfx

func cut() -> void:
	explode.emit()
	cuts.global_position = global_position
	cuts.play()
	cuts.global_rotation = global_rotation
	_add_sfx()
	queue_free()

func _add_sfx() -> void:
	var c = sfx.duplicate()
	c.finished.connect(c.queue_free)
	get_tree().get_root().add_child(c)
	c.play()
