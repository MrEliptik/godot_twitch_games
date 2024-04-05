extends Node2D

enum GAME_STATE {WAITING, RUNNING, WINNER, PAUSED}

@export var bullet_scene: PackedScene = preload("res://scenes/games/cannon/bullet.tscn")
@export var default_countdown: float = 3.0
@export var minimum_distance: float = 300.0

var state: GAME_STATE = GAME_STATE.WAITING
var viewers: Dictionary = {}

var viewers_to_add: Array = []

var player_goal_list: Dictionary = {}

@onready var viewer_container: Node2D = $ViewerContainer
@onready var cannon: Node2D = $Cannon
@onready var cannon_sprite: Sprite2D = $Cannon/Sprite2D
@onready var target: Area2D = $Target

@onready var join_next_round: Label = $JoinNextRound
@onready var how_to_play: Label = $HowToPlay
@onready var waiting: Label = $CanvasLayer/Waiting
@onready var countdown: Label = $CanvasLayer/Countdown

func _ready() -> void:
	GameConfigManager.load_config()

	GiftSingleton.viewer_joined.connect(on_viewer_joined)
	GiftSingleton.viewer_left.connect(on_viewer_left)
	GiftSingleton.user_left_chat.connect(on_viewer_left_chat)

	# Command: !fire 90 100
	GiftSingleton.add_game_command("fire", on_viewer_fire, 2, 2)
	GiftSingleton.add_alias("fire", "f")

	GiftSingleton.streamer_start.connect(on_streamer_start)
	GiftSingleton.streamer_wait.connect(on_streamer_wait)

	SignalBus.transparency_toggled.connect(on_transparency_toggled)

	change_state(GAME_STATE.WAITING)
	Transition.hide_transition()
	
	await get_tree().create_timer(10.0).timeout
	
	change_state(GAME_STATE.RUNNING)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		GameConfigManager.save_config()
		SceneSwitcher.change_scene_to(SceneSwitcher.selection_scene, true, null)

	#TODO: Move to a global shortcut script and/or to command window
	if Input.is_action_just_pressed("transparent"):
		SignalBus.emit_transparency_toggled(not get_viewport().transparent_bg)

func change_state(new_state: GAME_STATE) -> void:
	state = new_state
	match state:
		GAME_STATE.WAITING:
			waiting.visible = true
			join_next_round.visible = false
		GAME_STATE.RUNNING:
			waiting.visible = false
			join_next_round.visible = true
		GAME_STATE.WINNER:
			pass
		GAME_STATE.PAUSED:
			pass

func next_round() -> void:
	change_state(GAME_STATE.RUNNING)

	for viewer in viewers_to_add:
		spawn_viewer(viewer)

	viewers_to_add.clear()

	change_positions()

func change_positions() -> void:
	cannon.global_position = Vector2(randf_range(150, 1800), randf_range(400, 900))
	while true:
		target.global_position = Vector2(randf_range(150, 1800), randf_range(100, 900))
		if target.global_position.distance_to(cannon.global_position) > minimum_distance:
			break
	target.rotation_degrees = randf_range(0.0, 360.0)

func fire_viewer(viewer_name: String, angle: float, power: float) -> void:
	if not viewers.has(viewer_name):
		await spawn_viewer(viewer_name)
		fire_viewer(viewer_name, angle, power)

	# Move the viewer
	viewers[viewer_name].start_move()
	viewers[viewer_name].set_deferred("global_position", cannon.global_position)

	# Rotate cannon
	# Adds - to angle to go from 0 to -180 and keep it positive for viewers
	cannon_sprite.rotation_degrees = -angle

	# Send viewer
	viewers[viewer_name].call_deferred("stop_move")
	var impulse: Vector2 = cannon_sprite.global_transform.x * remap(power, 0.0, 100.0, 0.0, 4000.0)
	viewers[viewer_name].call_deferred("apply_central_impulse", impulse)

	cannon.call_deferred("shoot")

func spawn_viewer(viewer_name: String) -> RigidBody2D:
	if viewers.has(viewer_name): return

	var instance: RigidBody2D = bullet_scene.instantiate()
	instance.viewer_name = viewer_name
#	instance.freeze = true
	viewer_container.call_deferred("add_child", instance)
	viewers[viewer_name] = instance
	await instance.ready
	instance.position.x += randf_range(-600, 600)
	push_bullet(instance)
	return instance

func push_bullet(obj: RigidBody2D) -> void:
	var push_vec: Vector2 = obj.global_transform.x.rotated(deg_to_rad(randi_range(0, 360)))
	push_vec *= 650.0
	obj.apply_central_impulse(push_vec)

func remove_viewer(viewer_name: String) -> void:
	if not Viewers.is_joined(viewer_name): return
	Viewers.remove(viewer_name)

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

func on_streamer_start(arg_arr : PackedStringArray) -> void:
	var countdown_duration: float = default_countdown
	if not arg_arr.is_empty():
		if arg_arr[0].is_valid_float():
			countdown_duration = float(arg_arr[0])
	countdown.start(countdown_duration)

func on_streamer_wait(cmd_info : CommandInfo) -> void:
	change_state(GAME_STATE.WAITING)

func _on_target_body_entered(body: Node2D) -> void:
	if not (player_goal_list.has(body.get_node("Name").text)):
		player_goal_list[body.get_node("Name").text] = 1
	else:
		player_goal_list[body.get_node("Name").text] += 1
	
	
	target.activate()
	change_state(GAME_STATE.WINNER)
	next_round()

func _on_countdown_finished() -> void:
	next_round()

func on_transparency_toggled(transparent: bool) -> void:
	for node in get_tree().get_nodes_in_group("Background"):
		node.visible = not transparent
		get_viewport().transparent_bg = transparent

func _on_leaderboard_pressed():
	Leaderboard.list = player_goal_list
	get_tree().change_scene_to_file("res://scenes/ui/leaderboard.tscn")
