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
	GiftSingleton.viewer_joined.connect(on_viewer_joined)
	GiftSingleton.viewer_left.connect(on_viewer_left)
	GiftSingleton.user_left_chat.connect(on_viewer_left_chat)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		animation_player.play("move")

func spawn_viewer(viewer_name: String) -> void:
	if Viewers.is_viewer_joined(viewer_name): return
	Viewers.add_viewer(viewer_name)
	var instance = marble.instantiate()
	instance.viewer_name = viewer_name
	viewer_container.call_deferred("add_child", instance)
	await instance.ready
	push_marble(instance)
	
func remove_viewer(viewer_name: String) -> void:
	if not Viewers.is_viewer_joined(viewer_name): return
	Viewers.remove_viewer(viewer_name)
	
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
