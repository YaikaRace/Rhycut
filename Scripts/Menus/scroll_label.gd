@tool
class_name ScrollLabel extends ScrollContainer


@export var color: Color = Color("ffffeb"):
	set(new_color):
		color = new_color
		if is_node_ready():
			label.add_theme_color_override("font_color", new_color)

@export var text: String = "Placeholder":
	set(new_text):
		text = new_text
		if is_node_ready():
			label.text = new_text

@export var centered: bool = false:
	set(new_val):
		centered = new_val
		if not Engine.is_editor_hint():
			return
		if new_val:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		else:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

@export var waiting_time: float = 3.0
@export var speed: float = 20.0

@onready var label: Label = %label

var tween: Tween
var inverted = false

func _ready() -> void:
	label.add_theme_color_override("font_color", color)
	label.text = text
	if centered:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	await get_tree().create_timer(waiting_time).timeout
	start_tween()

func start_tween() -> void:
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	if not inverted:
		tween.tween_property(self, "scroll_horizontal", scroll_horizontal + 1, 1 / speed)
	else:
		tween.tween_property(self, "scroll_horizontal", scroll_horizontal - 1, 1 / speed)
	tween.finished.connect(start_tween)
	if scroll_horizontal >= get_h_scroll_bar().max_value - size.x:
		await get_tree().create_timer(waiting_time).timeout
		inverted = true
	elif scroll_horizontal <= 0:
		await get_tree().create_timer(waiting_time).timeout
		inverted = false
