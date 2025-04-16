extends Character

@export var bullet_scene : PackedScene

var last_direction : float = 1.0
var dead : bool = false
var controls_enabled : bool = true

func _ready() -> void:
	spawn()

func _physics_process(delta: float) -> void:
	var on_floor : bool = is_on_floor()
	
	#Handle gravity
	if !on_floor:
		velocity += get_gravity() * delta
		falling = true
	else:
		if falling:
			falling = false
			landed.emit()
	
	#Handle jumping
	if Input.is_action_just_pressed(&"up") and on_floor and controls_enabled:
		velocity.y = jump_velocity
		jumped.emit()
	
	#Handle movement
	var direction := Input.get_axis(&"left", &"right")
	if direction and controls_enabled:
		last_direction = direction
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	#Perform physics
	move_and_slide()
	moved.emit(velocity, direction != 0, on_floor)
	
	
	
	#Handle shooting
	if Input.is_action_just_pressed("shoot") and controls_enabled:
		var bullet : Projectile = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		bullet.direction.x = last_direction

func spawn() -> void:
	#Respawn the player at the start position
	var spawn_position : Node2D = get_tree().get_first_node_in_group("player_start_position")
	global_position = spawn_position.global_position
	
	dead = false
	controls_enabled = true
	spawned.emit()

func kill() -> void:
	if dead: return
	super.kill()
	dead = true
	controls_enabled = false
	
	await get_tree().create_timer(1.0).timeout
	spawn()
