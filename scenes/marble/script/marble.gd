extends RigidBody2D

var viewer_name: String

@onready var name_lbl: Label = $Name
@onready var label_offset: Vector2

func _ready():
	label_offset = name_lbl.position
	modulate = Color.from_hsv(randf_range(0.0, 1.0), 1.0, 1.0, 1.0)
	name_lbl.text = viewer_name
	name_lbl.top_level = true
	name_lbl.modulate = modulate

func _process(delta: float) -> void:
	name_lbl.global_position = global_position + label_offset
