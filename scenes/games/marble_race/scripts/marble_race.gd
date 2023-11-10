extends Node2D

@export var marble: PackedScene = preload("res://scenes/marble/marble.tscn")

#var total_not_typed = 0
#var total_infered := 0
#var total_typed: int = 0
#
#var str: String = ""

@onready var viewer_container: Node2D = $ViewerContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	GameConfigManager.load_config()

	GiftSingleton.viewer_joined.connect(on_viewer_joined)
	GiftSingleton.viewer_left.connect(on_viewer_left)
	GiftSingleton.user_left_chat.connect(on_viewer_left_chat)

	SignalBus.transparency_toggled.connect(on_transparency_toggled)

	Transition.hide_transition()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		animation_player.play("move")

	if Input.is_action_just_pressed("ui_cancel"):
		GameConfigManager.save_config()
		SceneSwitcher.change_scene_to(SceneSwitcher.selection_scene, true, null)

	#TODO: Move to a global shortcut script and/or to command window
	if Input.is_action_just_pressed("transparent"):
		SignalBus.emit_transparency_toggled(not get_viewport().transparent_bg)

func spawn_viewer(viewer_name: String) -> void:
	if viewer_container.has_node(viewer_name): return

	var instance = marble.instantiate()
	instance.name = viewer_name
	instance.viewer_name = viewer_name
	viewer_container.call_deferred("add_child", instance)

	await instance.ready
	push_marble(instance)

func remove_viewer(viewer_name: String) -> void:
	if not Viewers.is_joined(viewer_name): return

	for child in viewer_container.get_children():
		if child.viewer_name != viewer_name: continue
		child.queue_free()

func push_marble(obj: RigidBody2D) -> void:
	var push_vec: Vector2 = obj.global_transform.x.rotated(deg_to_rad(randi_range(0, 360)))
	push_vec *= 100.0
	obj.apply_central_impulse(push_vec)

##### SIGNALS #####
func on_viewer_joined(viewer_name: String) -> void:
	spawn_viewer(viewer_name)

func on_viewer_left(viewer_name: String) -> void:
	remove_viewer(viewer_name)

func on_viewer_left_chat(sender_data: SenderData) -> void:
	remove_viewer(sender_data.user)

func on_transparency_toggled(transparent: bool) -> void:
	for node in get_tree().get_nodes_in_group("Background"):
		node.visible = not transparent
		get_viewport().transparent_bg = transparent
