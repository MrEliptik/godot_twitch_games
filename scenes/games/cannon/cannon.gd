extends Node2D

enum GAME_STATE {WAITING, RUNNING, WINNER, PAUSED}

@export var bullet_scene: PackedScene = preload("res://scenes/games/cannon/bullet.tscn")

var state: GAME_STATE = GAME_STATE.WAITING
var viewers: Dictionary = {}

var viewers_to_add: Array = []

@onready var viewer_container: Node2D = $ViewerContainer
@onready var cannon: Node2D = $Cannon
@onready var target: Area2D = $Target

func _ready() -> void:
	GiftSingleton.viewer_joined.connect(on_viewer_joined)
	GiftSingleton.viewer_left.connect(on_viewer_left)
	GiftSingleton.user_left_chat.connect(on_viewer_left_chat)
	# Command: !fire 90
	GiftSingleton.add_command("fire", on_viewer_fire, 2, 2)
	
	GiftSingleton.add_command("start", on_streamer_start, 0, 0, GiftSingleton.PermissionFlag.STREAMER)
	GiftSingleton.add_command("wait", on_streamer_wait, 0, 0, GiftSingleton.PermissionFlag.STREAMER)
	
	Transition.hide_transition()
	
#	if state == GAME_STATE.WAITING:
#		await get_tree().create_timer(8.0).timeout
#		state = GAME_STATE.RUNNING

func _process(delta: float) -> void:
	pass

func next_round() -> void:
	state = GAME_STATE.RUNNING
	
	for viewer in viewers_to_add:
		spawn_viewer(viewer)
		
	viewers_to_add.clear()
	
	change_positions()

func change_positions() -> void:
	cannon.global_position = Vector2(randf_range(150, 1800), randf_range(400, 900))
	target.global_position = Vector2(randf_range(150, 1800), randf_range(100, 900))
	target.rotation_degrees = randf_range(0.0, 360.0)
	state = GAME_STATE.RUNNING

func fire_viewer(viewer_name: String, angle: float, power: float) -> void:
	if not viewers.has(viewer_name): return
	
	# Move the viewer
	viewers[viewer_name].freeze = true
	viewers[viewer_name].set_deferred("global_position", cannon.global_position)
	
	# Rotate cannon
	# Adds - to angle to go from 0 to -180 and keep it positive for viewers
	cannon.rotation_degrees = -angle
	
	# Send viewer
	viewers[viewer_name].set_deferred("freeze", false)
	var impulse: Vector2 = cannon.global_transform.x * remap(power, 0.0, 100.0, 0.0, 4000.0)
	viewers[viewer_name].call_deferred("apply_central_impulse", impulse)

func spawn_viewer(viewer_name: String) -> void:
	if Viewers.is_viewer_joined(viewer_name): return
	Viewers.add_viewer(viewer_name)
	var instance: RigidBody2D = bullet_scene.instantiate()
	instance.viewer_name = viewer_name
#	instance.freeze = true
	viewer_container.call_deferred("add_child", instance)
	viewers[viewer_name] = instance

func remove_viewer(viewer_name: String) -> void:
	if not Viewers.is_viewer_joined(viewer_name): return
	Viewers.remove_viewer(viewer_name)

	viewers[viewer_name].queue_free()
	viewers.erase(viewer_name)
#
#	for child in viewer_container.get_children():
#		if child.viewer_name != viewer_name: continue
#		child.queue_free()

##### SIGNALS #####
func on_viewer_joined(viewer_name: String) -> void:
	if state != GAME_STATE.WAITING: 
		viewers_to_add.append(viewer_name)
		return
	
	spawn_viewer(viewer_name)

func on_viewer_left(viewer_name: String) -> void:
	remove_viewer(viewer_name)

func on_viewer_left_chat(sender_data: SenderData) -> void:
	remove_viewer(sender_data.user)
	
func on_viewer_fire(cmd_info : CommandInfo, arg_arr : PackedStringArray) -> void:
	if state != GAME_STATE.RUNNING: return
	if not arg_arr[0].is_valid_float(): return
	if not arg_arr[1].is_valid_float(): return
	
	var angle: float = float(arg_arr[0])
	var power: float = float(arg_arr[1])
	fire_viewer(cmd_info.sender_data.tags["display-name"], angle, power)
	
func on_streamer_start(cmd_info : CommandInfo) -> void:
	next_round()
	
func on_streamer_wait(cmd_info : CommandInfo) -> void:
	state = GAME_STATE.WAITING

func _on_target_body_entered(body: Node2D) -> void:
	state = GAME_STATE.WINNER
	next_round()
