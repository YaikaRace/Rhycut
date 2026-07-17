class_name GravityComponent extends Node

var gravity = Globals.note_gravity

func get_position_vector(initial_position: Vector2, initial_velocity: Vector2, time: float) -> Vector2:
	var new_x = initial_position.x + initial_velocity.x * time
	var new_y = initial_position.y + initial_velocity.y * time + 0.5 * (gravity * 60) * time ** 2
	return Vector2(new_x, new_y)

func get_rotation_by_time(initial_angular_velocity: float, time: float) -> float:
	var final_rotation = deg_to_rad(initial_angular_velocity) * time
	final_rotation = wrapf(final_rotation, 0, 360)
	return final_rotation
