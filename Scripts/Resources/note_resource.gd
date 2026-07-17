class_name NoteResource extends Resource

@export_enum("note", "bomb") var type = 0
@export var time = 0.0
@export var spawn_pos = Vector2.ZERO

var idx = 0
var initial_position = Vector2.ZERO
var initial_velocity = Vector2.ZERO
var initial_angular_velocity = 0
var time_to_peak = 0.0

func _init(note_type: int = 0, spawn_at_time: float = 0.0, spawn_at_position: Vector2 = Vector2.ZERO) -> void:
	self.type = note_type
	self.time = spawn_at_time
	self.spawn_pos = spawn_at_position
