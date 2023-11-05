extends StaticBody2D

@export var bump_force: float = 1000.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Players"): return
	
	animation_player.play("bump")
	var dir: Vector2 = (body.global_position - global_position).normalized()
	dir = Vector2(sign(dir.x), sign(dir.y))
	print("Dir: ", dir)
	body.apply_central_impulse((dir * bump_force) + (dir * body.linear_velocity.length()))
