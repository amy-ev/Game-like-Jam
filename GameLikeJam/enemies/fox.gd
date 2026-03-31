extends CharacterBody3D

#var player = null
#@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $sprite
@onready var wander_controller = $wander_controller
@onready var ray = $RayCast3D
@onready var stats = $fox_stats
var player: CharacterBody3D = null
enum{
	idle,
	wander,
	chase,
	hurt,
	dead
}

var acceleration = 10
var speed = 5
var friction = 200

var state = idle

var facing_direction = Vector3(0,0, -1)
var player_detected = false
var player_in_area = false
var view_distance = 10.0
var view_angle = 40.0

func _physics_process(delta: float) -> void:
	#if not is_instance_valid(player):
		#player = get_tree().get_first_node_in_group("player")
	#
	if Global.player != null:
		player = Global.player
		
	if wander_controller.start_pos == null:
		wander_controller.start_pos = position
	
	if state != hurt and state != dead:
		seek_player()
	
	match state:
		idle:
			velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
			if player_in_area:
				var look_dir = global_position.direction_to(player.global_position)
				facing_direction = look_dir
				update_animation(Vector3.ZERO, delta)
			else:
				update_animation(Vector3.ZERO, delta)
			check_state()
		wander:
			var direction = position.direction_to(wander_controller.target_pos)
			
			if player_in_area:
				velocity = velocity.move_toward(Vector3.ZERO,friction *delta)
				var look_dir = global_position.direction_to(player.global_position)
				facing_direction = look_dir
				update_animation(Vector3.ZERO, delta)
			else:
				check_state()
				update_animation(direction,delta)
				
				if position.distance_to(wander_controller.target_pos)<=2:
					state = pick_state([idle,wander])
					wander_controller.start_timer((randi_range(1,3)))
		chase:
			if player_detected:
				var direction = global_position.direction_to(player.global_position)
				update_animation(direction, delta)
			else:
				state = idle
		hurt:
			velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		dead:
			velocity = Vector3.ZERO
	move_and_slide()
	
func check_state():
	if wander_controller.get_time_left() == 0:
		state = pick_state([idle,wander])
		wander_controller.start_timer(randi_range(1,3))
		
func pick_state(states):
	states.shuffle()
	return states.pop_front()
	
func update_animation(direction,delta):
	velocity = velocity.move_toward(direction * speed, acceleration * delta)

	if velocity.length() > 0.1:
		facing_direction = velocity.normalized()
		
	var anim_dir = get_animation_dir(facing_direction)

	if velocity.length() < 0.1:
		sprite.play(anim_dir + "_idle")
	else:
		sprite.play(anim_dir + "_move")

func get_animation_dir(dir):
	if player == null:
		return "front"
	var camera = player.get_node("Camera3D")
	
	var cam_forward = -camera.global_transform.basis.z
	var cam_right = camera.global_transform.basis.x
	
	cam_forward.y = 0
	cam_right.y = 0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()
	
	var x = dir.dot(cam_right)
	var z = dir.dot(cam_forward)
	
	var angle = atan2(x,z)
	var degrees = rad_to_deg(angle)
	if degrees > -45 and degrees <= 45:
		return "back"
	elif degrees > 45 and degrees <= 135:
		return "right"
	elif degrees > 135 or degrees <= -135:
		return "front"
	else:
		return "left"
		

func seek_player():
	if player == null:
		player_detected = false
		return
		
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player > view_distance:
		player_detected = false
		return
	
	var direction_to_player = global_position.direction_to(player.global_position)
	
	var dot = facing_direction.dot(direction_to_player)
	if dot <= cos(deg_to_rad(view_angle)):
		player_detected = false
		return

	var world_target = global_position + (direction_to_player * view_distance)
	ray.target_position = ray.to_local(world_target)
	ray.enabled = true
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider == player:
			player_detected = true
			state = chase
	
		elif collider is Area3D and collider.owner == player:
				player_detected = true
				state = chase
	else:
		player_detected = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		print("hello")
		player_in_area = true
		
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		player_in_area = false


func _on_hurtbox_area_entered(area: Area3D) -> void:
	if area.name == "hitbox":
		if area.owner == player:
			
			var direction = (global_position - player.global_position).normalized()
			velocity = direction * player.knockback
			var damage_value = player.damage
			stats.health -= damage_value
			if state == dead:
				return
			state = hurt
			sprite.play("hurt")
			print(stats.health)


func _on_fox_stats_no_health() -> void:
	state = dead
	sprite.play("death")

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "hurt" and state != dead:
		state = idle
	if sprite.animation == "death":
		queue_free()
