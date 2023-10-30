extends RigidBody2D

var viewer_name: String

@onready var name_lbl: Label = $Name
@onready var label_offset: Vector2
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var trail: GPUParticles2D = $Trail
@onready var trail_2d: Line2D = $Trail2D

func _ready():
	label_offset = name_lbl.position
	var color: Color = Color.from_hsv(randf_range(0.0, 1.0), 1.0, 1.0, 1.0)
	sprite_2d.modulate = color
	trail_2d.modulate = color
	name_lbl.set("theme_override_colors/font_color", color)
	trail.modulate = color
	name_lbl.text = viewer_name
	name_lbl.top_level = true
	name_lbl.modulate = modulate

func _process(delta: float) -> void:
	name_lbl.global_position = global_position + label_offset
