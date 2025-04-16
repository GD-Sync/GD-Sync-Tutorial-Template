extends CharacterBody2D
class_name Character

signal spawned
signal moved(velocity : Vector2, moving : bool, on_floor : bool)
signal jumped
signal landed
signal died

@export var speed = 200.0
@export var jump_velocity = -350.0

var falling : bool = false

func kill() -> void:
	died.emit()
