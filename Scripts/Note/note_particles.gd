extends Node2D

@onready var left: GPUParticles2D = %left
@onready var right: GPUParticles2D = %right

func set_angle(angle: float) -> void:
	(left.process_material as ParticleProcessMaterial).angle_min = angle
	(left.process_material as ParticleProcessMaterial).angle_max = angle
	(right.process_material as ParticleProcessMaterial).angle_min = angle
	(right.process_material as ParticleProcessMaterial).angle_max = angle

func start(angle = 0.0) -> void:
	set_angle(-angle)
	left.emitting = true
	right.emitting = true

func _on_finished() -> void:
	queue_free()
