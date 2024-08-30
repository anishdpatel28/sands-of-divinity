extends Node

@export var player : CharacterBody3D
@export var anim_tree : AnimationTree

var tween : Tween
var num_afk_anims : Array = [5, 1]
var anim_before_afk : String = "upright"
var last_movement_state : MovementState

func _ready() -> void:
	anim_tree.active = true
	anim_tree.set("parameters/StateMachine/Basic Movement/blend_position", Vector2.ZERO)

func handle_animations(movement_state: MovementState, Xfade_time: float = 0.25) -> void:
	last_movement_state = movement_state
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	# Blend Position x --> Played animation - MovementState ID
	# Blend Position y --> stance_state: 0=Upright, 1=Crouch
	var movement_vector : Vector2 = Vector2(movement_state.id, movement_state.stance_state)
	tween.tween_property(anim_tree, "parameters/StateMachine/Basic Movement/blend_position", movement_vector, Xfade_time).set_ease(Tween.EASE_IN_OUT)

func on_afk_triggered() -> void:
	var random_afk_anim = randi() % (num_afk_anims[last_movement_state.stance_state])
	anim_before_afk = player.current_stance_name
	
	anim_tree.set("parameters/StateMachine/AFK/blend_position", Vector2(random_afk_anim, last_movement_state.stance_state))
	anim_tree.set("parameters/StateMachine/conditions/afk", true)

func afk_condition_false() -> void:
	anim_tree.set("parameters/StateMachine/conditions/afk", false)
	var state_machine_playback = anim_tree.get("parameters/StateMachine/playback")
	state_machine_playback.travel("Basic Movement")
	handle_animations(last_movement_state)

func jump() -> void:
	anim_tree.set("parameters/StateMachine/conditions/jump", true)

func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	if player.afk_timer.get_time_left() == 0:
		player.reset_afk_timer()

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if (anim_name == "Jump"):
		anim_tree.set("parameters/StateMachine/conditions/jump", false)
