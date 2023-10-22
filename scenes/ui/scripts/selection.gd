extends Control

@onready var grid_container = $GridContainer

func _ready() -> void:
	for c in grid_container.get_children():
		c.pressed.connect(on_btn_pressed.bind(c.scene))

func on_btn_pressed(scene: PackedScene) -> void:
	Transition.show_transition()
	await Transition.done
	get_tree().change_scene_to_packed(scene)
