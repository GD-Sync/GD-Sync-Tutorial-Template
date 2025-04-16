extends AudioStreamPlayer2D

@export var auto_play : bool = false
@export var pitch_range : float = 0.1

var original_scale : float = 1.0

func _ready() -> void:
	original_scale = pitch_scale
	
	if auto_play:
		play_randomized()

func play_randomized() -> void:
	pitch_scale = original_scale + randf_range(-pitch_range, pitch_range)
	play()
