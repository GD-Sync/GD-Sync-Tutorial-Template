extends Node2D

signal picked_up

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !visible: return
	
	picked_up.emit()
	visible = false
	
	get_tree().get_first_node_in_group("coin_menu").coin_collected()
