extends Node

@export var player : CharacterBody3D
@export var mesh_root : Node3D
@export var rotation_speed : float = 8
@export var fall_gravity = 45
var jump_gravity : float = fall_gravity
var direction : Vector3
var velocity : Vector3
var acceleration : float
var speed : float
var cam_rotation : float = 0

func _physics_process(delta):
	velocity.x = speed * direction.normalized().x
	velocity.z = speed * direction.normalized().z
	
	if not player.is_on_floor():
		if velocity.y >= 0:
			velocity.y -= jump_gravity * delta
		else:
			velocity.y -= fall_gravity * delta
	
	player.velocity = player.velocity.lerp(velocity, acceleration * delta)
	player.move_and_slide()
	
	var target_rotation = atan2(direction.x, direction.z) - player.rotation.y
	
	mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)

func jump():
	var jump_height = 1
	var apex_duration = 0.5
	velocity.y = 2 * jump_height / apex_duration
	jump_gravity = velocity.y / apex_duration

func on_set_movement_state(movement_state: MovementState):
	speed = movement_state.movement_speed
	acceleration = movement_state.acceleration

func on_set_movement_direction(movement_direction: Vector3):
	if not player.is_on_floor():
		return
	
	direction = movement_direction.rotated(Vector3.UP, cam_rotation)

func on_set_cam_rotation(new_cam_rotation: float):
	cam_rotation = new_cam_rotation
