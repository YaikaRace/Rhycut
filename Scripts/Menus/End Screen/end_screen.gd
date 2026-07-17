extends CanvasLayer

@onready var p_count: Label = %p_count
@onready var gr_count: Label = %gr_count
@onready var g_count: Label = %g_count
@onready var b_count: Label = %b_count
@onready var m_count: Label = %m_count
@onready var accuracy_label: Label = %accuracy_label
@onready var rank_label: Label = %rank_label

func _ready() -> void:
	hide()

func show_data(data: Dictionary) -> void:
	if visible:
		return
	show()
	p_count.text = str(floori(data.perfect))
	gr_count.text = str(floori(data.great))
	g_count.text = str(floori(data.good))
	b_count.text = str(floori(data.bad))
	m_count.text = str(data.miss)
	accuracy_label.text = str(data.accuracy).pad_decimals(1) + "%"
	calculate_rank(data)

func calculate_rank(data: Dictionary) -> void:
	if data.loss:
		rank_label.text = "F"
		rank_label.label_settings.font_color = Color("606070")
		return
	var accuracy: float = data.accuracy
	if accuracy >= 100.0:
		rank_label.text = "S+"
		rank_label.label_settings.font_color = Color("ffe478")
	elif accuracy >= 95.0:
		rank_label.text = "S"
		rank_label.label_settings.font_color = Color("ffe478")
	elif accuracy >= 90.0:
		rank_label.text = "A"
		rank_label.label_settings.font_color = Color("4da6ff")
	elif accuracy >= 85.0:
		rank_label.text = "B"
		rank_label.label_settings.font_color = Color("8fde5d")
	elif accuracy >= 80.0:
		rank_label.text = "C"
		rank_label.label_settings.font_color = Color("b0305c")
	elif accuracy >= 70.0:
		rank_label.text = "D"
		rank_label.label_settings.font_color = Color("606070")
	else:
		rank_label.text = "F"
		rank_label.label_settings.font_color = Color("606070")

func _on_restart_pressed() -> void:
	GameState.reset_level()
	get_tree().reload_current_scene()

func _on_back_to_menu_pressed() -> void:
	GameState.reset_state()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
