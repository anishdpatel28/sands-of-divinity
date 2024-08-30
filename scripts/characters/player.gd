extends CharacterBody3D

signal pressed_jump()
signal changed_stance(stance : Stance)
signal changed_movement_state(movement_state: MovementState)
signal changed_movement_direction(movement_direction: Vector3)
signal reset_afk()

@export var stances : Dictionary
@export var afk_timer : Timer

var movement_direction : Vector3
var current_stance_name : String = "upright"
var current_movement_state_name : String
var stance_antispam_timer : SceneTreeTimer
var afk_min_time : int = 15
var afk_max_time : int = 30
var is_sprinting : bool = false
var is_jumping : bool = false
var queued_stance : String = ""
var spam_time : float = 0.1

func _ready() -> void:
	reset_antispam_timer()
	
	changed_movement_direction.emit(Vector3.BACK)
	set_movement_state("stand")
	set_stance(current_stance_name)
	
	reset_afk_timer()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("movement") or event.is_action_released("movement"):
		reset_afk_timer()
		movement_direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
		movement_direction.z = Input.get_action_strength("forward") - Input.get_action_strength("backward")
		
		if is_movement_ongoing():
			if Input.is_action_pressed("sprint") or is_sprinting:
				is_sprinting = true
				set_movement_state("sprint")
			else:
				set_movement_state("walk")
		else:
			is_sprinting = false
			set_movement_state("stand")
	
	if event.is_action_pressed("jump"):
		reset_afk_timer()
		if not is_jumping and is_on_floor():
			if current_stance_name != "upright":
				set_stance("upright")
				return
			
			pressed_jump.emit()
			is_jumping = true
	
	for stance in stances.keys():
		if event.is_action_pressed(stance):
			reset_afk_timer()
			if is_on_floor():
				set_stance(stance)
			else:
				queued_stance = stance

func _physics_process(_delta: float) -> void:
	if is_movement_ongoing():
		changed_movement_direction.emit(movement_direction)
	
	if is_on_floor():
		if queued_stance:
			set_stance(queued_stance)
			queued_stance = ""
		is_jumping = false
	elif is_jumping == false:
		is_jumping = true

func reset_antispam_timer() -> void:
	stance_antispam_timer = await get_tree().create_timer(spam_time)

func reset_afk_timer() -> void:
	reset_afk.emit()
	afk_timer.start(randi() % (afk_max_time - afk_min_time + 1) + afk_min_time)

func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0

func set_movement_state(state : String) -> void:
	var stance = get_node(stances[current_stance_name])
	current_movement_state_name = state
	changed_movement_state.emit(stance.get_movement_state(state))

func set_stance(stance_name : String) -> void:
	if stance_antispam_timer.time_left > 0:
		return
	
	reset_antispam_timer()
	
	var next_stance_name : String
	
	if stance_name == current_stance_name:
		next_stance_name = "upright"
	else:
		next_stance_name = stance_name
	
	if is_stance_blocked(next_stance_name):
		return
	
	var current_stance = get_node(stances[current_stance_name])
	current_stance.collider.disabled = true
	
	current_stance_name = next_stance_name
	current_stance = get_node(stances[current_stance_name])
	current_stance.collider.disabled = false
	
	changed_stance.emit(current_stance)
	set_movement_state(current_movement_state_name)

func is_stance_blocked(stance_name : String) -> bool:
	var stance = get_node(stances[stance_name])
	return stance.is_blocked()
