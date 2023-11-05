extends RigidBody2D

@export var blood_particles: PackedScene = preload("res://scenes/games/pool_royale/blood_particles.tscn")

var viewer_name: String

@onready var name_lbl: Label = $Name
@onready var label_offset: Vector2
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var trail_2d: Line2D = $Trail2D

func _ready():
	label_offset = name_lbl.position
	var color: Color = Color.from_hsv(randf_range(0.0, 1.0), 1.0, 1.0, 1.0)
	sprite_2d.modulate = color
	trail_2d.modulate = color
	name_lbl.set("theme_override_colors/font_color", color)
	name_lbl.text = viewer_name
	name_lbl.top_level = true
	name_lbl.modulate = modulate

func _process(delta: float) -> void:
	name_lbl.global_position = global_position + label_offset

func spawn_blood_particles() -> void:
	var instance: GPUParticles2D = blood_particles.instantiate()
	add_child(instance)

func start_move() -> void:
	freeze = true
	trail_2d.stop()
	
func stop_move() -> void:
	freeze = false
	trail_2d.start()

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Players"): return
	spawn_blood_particles()
