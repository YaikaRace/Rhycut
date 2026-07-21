extends Node

const TOAST = preload("uid://wpt6e0qude7i")
const GREEN_PANEL = preload("uid://ch8gfd6vedt0d")
const RED_PANEL = preload("uid://cot7sx3a52mjy")

var toast_container = CanvasLayer.new()

func _ready() -> void:
	toast_container.layer = 255
	get_tree().get_root().add_child.call_deferred(toast_container)

func show(title: String, info: String, image: Texture2D = null, pos_x: float = 0.0) -> void:
	create(title, info, image, GREEN_PANEL, pos_x)

func error(title: String, info: String, image: Texture2D = null, pos_x: float = 0.0) -> void:
	create(title, info, image, RED_PANEL, pos_x)

func create(title: String, info: String, image: Texture2D = null, panel: Texture2D = null, pos_x: float = 0.0) -> void:
	var ins = TOAST.instantiate()
	toast_container.add_child(ins)
	ins.set_toast(title, info, image, panel)
	ins.position.x = pos_x
	if pos_x == 0.0:
		ins.position.x = get_viewport().get_visible_rect().size.x / 2 - ins.size.x / 2
	ins.position.y = -35
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(ins, "position:y", 0, 0.2)
	ins.touched.connect(_on_toast_touched.bind(ins))
	await tween.finished
	var timer = get_tree().create_timer(3)
	ins.timer = timer
	await timer.timeout
	tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(ins, "position:y", -35, 0.2)
	await tween.finished
	ins.queue_free()

func _on_toast_touched(toast: PanelContainer) -> void:
	toast.timer.time_left = 0
