extends Node2D

@export var speed: float = 1.0

@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var remote_transform_2d: RemoteTransform2D = $Path2D/PathFollow2D/RemoteTransform2D

func _ready() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_loops()
	tween.tween_property(path_follow_2d, "progress_ratio", 1.0, speed)
	tween.tween_property(path_follow_2d, "progress_ratio", 0.0, speed)
	
func _process(delta: float) -> void:
	pass
