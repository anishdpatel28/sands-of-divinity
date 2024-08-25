extends Node

@export var player : CharacterBody3D
@export var anim_tree : AnimationTree
@export var anim_player : AnimationPlayer

var afk_anim_names : Array = ["Bellydancing"]

enum {IDLE, WALK, RUN}

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
	anim_tree.set("parameters/Bellydancing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func jump() -> void:
	anim_tree.set("parameters/Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name in afk_anim_names:
		player.reset_afk_timer()
