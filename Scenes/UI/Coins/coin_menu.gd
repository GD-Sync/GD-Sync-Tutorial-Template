extends Control

@export var coin_label : Label

var coins : int = 0

func coin_collected() -> void:
	coins += 1
	coin_label.text = str(coins)
