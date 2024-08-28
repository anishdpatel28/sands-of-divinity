extends Node

@export var player : CharacterBody3D
@export var anim_tree : AnimationTree
@export var anim_player : AnimationPlayer

var num_afk_anims : int = 4
var anim_before_afk : String = "upright"

func handle_animations(movement_state: MovementState):
	match movement_state.stance_state:
		0:
			anim_tree.set("parameters/Stance Transition/transition_request", "Upright")
			match movement_state.id:
				0:
					anim_tree.set("parameters/Upright Movement/transition_request", "Idle")
				1:
					anim_tree.set("parameters/Upright Movement/transition_request", "Walk")
				2:
					anim_tree.set("parameters/Upright Movement/transition_request", "Run")
		
		1:
			anim_tree.set("parameters/Stance Transition/transition_request", "Crouch")
			match movement_state.id:
				0:
					anim_tree.set("parameters/Crouch Movement/transition_request", "Idle")
				1:
					anim_tree.set("parameters/Crouch Movement/transition_request", "Walk")
				2:
					anim_tree.set("parameters/Crouch Movement/transition_request", "Run")

func on_afk_triggered() -> void:
	var random_afk_anim = randi() % (num_afk_anims + 1)
	anim_before_afk = player.current_stance_name
	anim_tree.set("parameters/BlendTree AFK/BlendSpace1D/blend_position", random_afk_anim)
	anim_tree.set("parameters/Stance Transition/transition_request", "AFK")

func jump() -> void:
	anim_tree.set("parameters/Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	if player.afk_timer.get_time_left() == 0:
		player.reset_afk_timer()
	player.set_stance(anim_before_afk)
