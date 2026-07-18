extends PanelContainer

@onready var toast_image: TextureRect = %image
@onready var title_label: Label = %title
@onready var info_label: Label = %info

func set_toast(title: String, info: String, image: Texture2D = null, panel: Texture2D = null):
	if image:
		toast_image.texture = image
		toast_image.show()
	title_label.text = title
	info_label.text = info
	if panel:
		var p = get_theme_stylebox("panel") as StyleBoxTexture
		p.texture = panel
