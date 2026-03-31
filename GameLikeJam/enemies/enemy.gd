extends CharacterBody3D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $sprite
@onready var wander_controller = $wander_controller

enum{
	idle,
	wander,
	chase
}

var acceleration = 10
var speed = 5
var friction = 200

var state = idle

var facing_direction = Vector3(0,0, -1)

func _physics_process(delta: float) -> void:
	if wander_controller.start_pos == null:
		wander_controller.start_pos = position
	
	match state:
		idle:
			velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
			update_animation(Vector3.ZERO, delta)

			check_state()
		wander:
			var direction = position.direction_to(wander_controller.target_pos)

			check_state()
			update_animation(direction,delta)
			
			if position.distance_to(wander_controller.target_pos)<=2:
				state = pick_state([idle,wander])
				wander_controller.start_timer((randi_range(1,3)))
		chase:
			pass
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
	elif degrees > 135 and degrees > -135:
		return "front"
	else:
		return "left"
