extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func activate() -> void:
	animation_player.play("go_through")
	await animation_player.animation_finished
	animation_player.play("go_through_loop")
