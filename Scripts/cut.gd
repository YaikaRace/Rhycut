extends Sprite2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

func play() -> void:
	animation_player.play("cut")
	if not audio_stream_player.playing:
		audio_stream_player.play()
