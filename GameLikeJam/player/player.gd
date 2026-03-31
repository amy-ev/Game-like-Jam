extends CharacterBody3D

@onready var CAMERA_CONTROLLER := $Camera3D
@onready var LIGHT_CONTROLLER := $Camera3D/SpotLight3D

@onready var avatar:= $gui/gui/panel/HBoxContainer/avatar/avatar
@onready var attack_sprite:= $"gui/attack-sprite"
@onready var arm:= $gui/arm
@onready var hitbox = $hitbox/CollisionShape3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 0.05

# maybe change to be adjustable
const MOUSE_SENSITIVITY := 0.5

const TILT_LOWER_LIMIT := -1.0
const TILT_UPPER_LIMIT := 1.0

var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3
var _light_rotation : Vector3

var knockback = 15
var damage = 10

func _ready():
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CAMERA_CONTROLLER.make_current()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	if attack_sprite.animation == "scratch":
		if attack_sprite.frame == 1:
			hitbox.disabled = true
			
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	#TODO: REMVOE THIS BEFORE EXPORT
	if Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_pressed("crouch"):
		velocity.y = -JUMP_VELOCITY
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	move_and_slide()
	_update_camera(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		hitbox.disabled = false
		play_attack_animations()
	
	
func play_attack_animations():
	attack_sprite.play("scratch")
	arm.play("scratch")
	avatar.play("attack")
	await avatar.animation_finished
	avatar.play("look-around")
	
		
func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)
	_light_rotation = Vector3(_mouse_rotation.x,0.0,0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	LIGHT_CONTROLLER.transform.basis = Basis.from_euler(_light_rotation)
	LIGHT_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)

	# to stop constant spinning
	_rotation_input = 0.0
	_tilt_input = 0.0
	

func _on_hurtbox_area_entered(area: Area3D) -> void:
		if area.name == "hitbox":
			print("oh my")
