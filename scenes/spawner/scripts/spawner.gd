extends Node2D

@export var marble: PackedScene = preload("res://scenes/marble/marble.tscn")

var tween: Tween

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		spawn_marbles(50)

func spawn_marbles(amount: int) -> void:
	var degree_rotate: float = 360.0 / amount

	if tween and tween.is_running(): tween.kill()
	tween = create_tween()
	tween.set_loops(amount)
	tween.tween_callback(spawn_marble)
	tween.tween_callback(rotate.bind(deg_to_rad(-degree_rotate)))
#	tween.tween_property(self, "rotation_degrees", rotation_degrees + degree_rotate, randf_range(0.1, 0.2))
	tween.tween_interval(0.05)

func spawn_marble() -> void:
	var instance = marble.instantiate()
	instance.global_position = global_position
	get_parent().call_deferred("add_child", instance)
	instance.call_deferred("apply_central_impulse", global_transform.x * 900.0)
