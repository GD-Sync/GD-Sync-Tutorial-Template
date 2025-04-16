extends Character

signal enemy_detected
signal enemy_lost

enum STATE {
	WANDER,
	ATTACK,
	DEAD
}

@export var body_size : float = 15
@export var wall_raycast : RayCast2D
@export var floor_raycast : RayCast2D

@export_group("Drops")
@export var drop_scene : PackedScene
@export var drop_amount_range : Vector2i

var current_state : STATE = STATE.WANDER
var target : Node2D

var respawn_timer : SceneTreeTimer

func _ready() -> void:
	spawn()

func spawn() -> void:
	spawned.emit()
	current_state = STATE.WANDER

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	var direction := 0.0
	var speed_mod := 1.0
	
	match(current_state):
		STATE.WANDER:
			direction = get_meta("wander_direction", 1)
			update_rays(direction)
			
			speed_mod = 0.5
			
			if wall_raycast.is_colliding():
				set_meta("wander_direction", -direction)
			if !floor_raycast.is_colliding():
				set_meta("wander_direction", -direction)
		STATE.ATTACK:
			direction = sign(target.position.x-position.x)
			update_rays(direction)
			
			if !floor_raycast.is_colliding():
				direction = 0.0
		STATE.DEAD:
			pass
	
	if direction:
		velocity.x = direction * speed * speed_mod
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	if current_state != STATE.DEAD:
		moved.emit(velocity, direction != 0, is_on_floor())

func update_rays(direction : float) -> void:
	wall_raycast.target_position.x = body_size*direction
	floor_raycast.position.x = body_size*direction
	wall_raycast.force_raycast_update()
	floor_raycast.force_raycast_update()

func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if current_state == STATE.DEAD: return
	
	if !is_instance_valid(target):
		target = body
		current_state = STATE.ATTACK
		
		enemy_detected.emit()

func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if current_state == STATE.DEAD: return
	
	if target == body:
		target = null
		current_state = STATE.WANDER
		
		enemy_lost.emit()

func kill() -> void:
	if current_state == STATE.DEAD: return
	current_state = STATE.DEAD
	super.kill()
	drop_items()
	
	await get_tree().create_timer(10).timeout
	spawn()

func drop_items() -> void:
	for i in randi_range(drop_amount_range.x, drop_amount_range.y):
		var drop : Node2D = drop_scene.instantiate()
		get_tree().current_scene.add_child(drop)
		drop.global_position = global_position
		
		var target_pos : Vector2 = position+Vector2(randf_range(-50, 50), 0)
		var time_mod : float = randf_range(0.9, 1.1)
		
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(drop, "global_position", (global_position+target_pos)/2+Vector2.UP*randf_range(20, 25), 0.2*time_mod)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(drop, "global_position", target_pos, 0.5*time_mod)
