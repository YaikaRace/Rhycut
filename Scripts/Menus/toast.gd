extends PanelContainer

signal touched

@onready var toast_image: TextureRect = %image
@onready var title_label: Label = %title
@onready var info_label: Label = %info

var timer: SceneTreeTimer

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)

func set_toast(title: String, info: String, image: Texture2D = null, panel: Texture2D = null) -> void:
	if image:
		toast_image.texture = image
		toast_image.show()
	title_label.text = title
	info_label.text = info
	if panel:
		var p = get_theme_stylebox("panel") as StyleBoxTexture
		p.texture = panel

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			touched.emit()
