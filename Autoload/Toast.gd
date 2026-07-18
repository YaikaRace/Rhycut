extends Node

const TOAST = preload("uid://wpt6e0qude7i")
const GREEN_PANEL = preload("uid://ch8gfd6vedt0d")
const RED_PANEL = preload("uid://cot7sx3a52mjy")

func show(title: String, info: String, image: Texture2D = null, pos_x: float = 0.0) -> void:
	create(title, info, image, GREEN_PANEL, pos_x)

func error(title: String, info: String, image: Texture2D = null, pos_x: float = 0.0) -> void:
	create(title, info, image, RED_PANEL, pos_x)

func create(title: String, info: String, image: Texture2D = null, panel: Texture2D = null, pos_x: float = 0.0) -> void:
	var ins = TOAST.instantiate()
	get_tree().root.add_child(ins)
	ins.set_toast(title, info, image, panel)
	ins.position.x = pos_x
	if pos_x == 0.0:
		ins.position.x = get_viewport().get_visible_rect().size.x / 2 - ins.size.x / 2
	ins.position.y = -35
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(ins, "position:y", 0, 0.2)
	await tween.finished
	await get_tree().create_timer(3).timeout
	tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(ins, "position:y", -35, 0.2)
	await tween.finished
	ins.queue_free()
