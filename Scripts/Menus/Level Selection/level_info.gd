extends VBoxContainer

@onready var icon: TextureRect = %icon
@onready var level_name: ScrollLabel = %level_name
@onready var author_name: ScrollLabel = %author_name
@onready var song_name: ScrollLabel = %song_name
@onready var song_author: ScrollLabel = %song_author
@onready var song_website: LinkButton = %song_website

func _ready() -> void:
	hide()

func set_metadata(data: Dictionary) -> void:
	show()
	var img = Image.new()
	img.data = data.icon
	icon.texture = ImageTexture.create_from_image(img)
	level_name.text = data.name
	author_name.text = data.author
	song_name.text = data.song_name
	song_author.text = "by " + data.song_author
	if data.has("song_website") and data.song_website:
		song_website.show()
		song_website.text = data.song_website
		song_website.uri = data.song_website
		if not data.song_website.begins_with("https://") and not data.song_website.begins_with("http://"):
			song_website.uri = "https://" + data.song_website
	else:
		song_website.hide()
