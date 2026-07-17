@tool
class_name VolumeController extends VBoxContainer

@export var control_name = "General"
@export var bus = "Master"
@export_range(0, 1, 0.01) var linear_volume = 1.0:
	set(new_val):
		linear_volume = new_val
		if Engine.is_editor_hint():
			set_volume(new_val * 100)

@onready var name_label: Label = $name_label
@onready var volume_slider: HSlider = %volume_slider
@onready var volume_spinbox: SpinBox = %volume_spinbox


func _ready() -> void:
	name_label.text = control_name
	set_volume(linear_volume * 100)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		name_label.text = control_name
		return

func _on_volume_spinbox_value_changed(value: float) -> void:
	set_volume(value)

func _on_volume_slider_value_changed(value: float) -> void:
	set_volume(value)

func set_volume(value: float) -> void:
	volume_slider.value = value
	volume_spinbox.value = value
	linear_volume = value / 100.0
