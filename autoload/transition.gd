extends CanvasLayer

signal done()

@export var shown: bool = false

@onready var animation_player = $AnimationPlayer

func show_transition() -> void:
	if shown: return
	animation_player.play("show")
	
func hide_transition() -> void:
	if not shown: return
	animation_player.play("hide")
