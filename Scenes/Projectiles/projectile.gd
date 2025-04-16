extends CharacterBody2D
class_name Projectile

@export var speed : float = 100.0
@export var lifetime : float = 10.0
var direction : Vector2 = Vector2.ZERO

var time : float = 0.0

func _physics_process(delta: float) -> void:
	var collision : KinematicCollision2D = move_and_collide(direction*speed*delta)
	
	time += delta
	
	if time > lifetime:
		queue_free()
	
	if collision != null:
		queue_free()
		
		var collider : Node = collision.get_collider()
		if collider is Character:
			collider.kill()
