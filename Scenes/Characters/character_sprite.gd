extends AnimatedSprite2D

@export var max_speed : float = 200.0

func _on_character_moved(velocity: Vector2, moving: bool, on_floor : bool) -> void:
	if moving:
		play("move")
		flip_h = velocity.x >= 0
		speed_scale = velocity.x/max_speed
	else:
		play("idle")
		speed_scale = 1

func died() -> void:
	play("dead")
