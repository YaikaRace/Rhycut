class_name Item extends CharacterBody2D

signal cut_time(time: float)
signal miss

@export var particles: PackedScene
@export var note_indicator = true

@onready var lifetime: Timer = %lifetime
@onready var sprite: Sprite2D = %sprite
@onready var gravity_component: GravityComponent = %GravityComponent

var resource: NoteResource

var gravity = Globals.note_gravity

var editor = false
var indicator: Sprite2D
var shadow: Sprite2D
var paused = false
var cuts: Sprite2D

func _ready() -> void:
	global_position = resource.initial_position
	if not editor:
		lifetime.start()
	if note_indicator and not GameState.is_modifier_active("no_indicators"):
		indicator = sprite.duplicate()
		indicator.show_behind_parent = true
		#indicator.scale = Vector2(1.5, 1.5)
		add_child(indicator)
		move_child(indicator, 0)
		var shader = ShaderMaterial.new()
		shader.shader = preload("uid://cblpif0rix61m")
		shader.set_shader_parameter("top", true)
		shader.set_shader_parameter("bottom", true)
		shader.set_shader_parameter("left", true)
		shader.set_shader_parameter("right", true)
		shader.set_shader_parameter("color", Color(1, 1, 1, 0.3))
		indicator.material = shader
		indicator.self_modulate.a = 0
	shadow = sprite.duplicate()
	shadow.material = shadow.material.duplicate()
	shadow.material.set_shader_parameter("color", Color("422445"))
	shadow.material.set_shader_parameter("quantity", 1.0)
	shadow.z_index = -1
	add_child(shadow)
	move_child(shadow, 0)
	shadow.global_position = sprite.global_position + Vector2(3, 3)

func _process(delta: float) -> void:
	global_position = calculate_current_position()
	sprite.rotation = calculate_current_rotation()
	shadow.rotation = sprite.rotation
	if indicator:
		indicator.global_position = gravity_component.get_position_vector(resource.initial_position, resource.initial_velocity, resource.time_to_peak)
		indicator.global_rotation = gravity_component.get_rotation_by_time(resource.initial_angular_velocity, resource.time_to_peak)
		var starting_time = resource.time - resource.time_to_peak
		var current_time = AudioHelper.time
		var remapped = remap(current_time, starting_time, resource.time, 2.0, 1.0)
		var clamped = clampf(remapped, 1.0, 2.0)
		indicator.scale = Vector2(clamped, clamped)
		if current_time > resource.time:
			indicator.hide()
		else:
			indicator.show()

#func _physics_process(delta: float) -> void:
	#global_position = calculate_current_position()
	#sprite.rotation = calculate_current_rotation()
	#shadow.rotation = sprite.rotation

func cut() -> void:
	return

func generate_particles() -> void:
	return

func _on_lifetime_timeout() -> void:
	queue_free()

func calculate_current_position() -> Vector2:
	var time_elapsed = _get_synced_time()
	_show_indicator()
	return gravity_component.get_position_vector(resource.initial_position, resource.initial_velocity, time_elapsed)

func _get_synced_time() -> float:
	var time = AudioHelper.time
	var time_elapsed = time - (resource.time - resource.time_to_peak)
	time_elapsed = max(time_elapsed, 0)
	return time_elapsed

func _show_indicator() -> void:
	if not indicator:
		return
	var time_elapsed = _get_synced_time()
	if time_elapsed <= 0:
		indicator.modulate.a = 0
	else:
		indicator.modulate.a = 1

func calculate_current_rotation() -> float:
	var time_elapsed = _get_synced_time()
	return gravity_component.get_rotation_by_time(resource.initial_angular_velocity, time_elapsed)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	screen_exited()

func screen_exited() -> void:
	return
