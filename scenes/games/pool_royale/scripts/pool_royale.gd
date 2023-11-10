extends Node2D

enum GAME_STATE {WAITING, RUNNING, WINNER, PAUSED}

@export var player_scene: PackedScene = preload("res://scenes/games/pool_royale/player.tscn")
@export var default_countdown: float = 3.0

var state: GAME_STATE = GAME_STATE.WAITING
var viewers: Dictionary = {}
var viewers_to_add: Array = []

@onready var viewer_container: Node2D = $ViewerContainer
@onready var waiting: Label = $CanvasLayer/Waiting
@onready var countdown: Label = $CanvasLayer/Countdown
#@onready var join_next_round: Label = $JoinNextRound
#@onready var how_to_play: Label = $HowToPlay

func _ready() -> void:
	GameConfigManager.load_config()

	GiftSingleton.viewer_joined.connect(on_viewer_joined)
	GiftSingleton.viewer_left.connect(on_viewer_left)
	GiftSingleton.user_left_chat.connect(on_viewer_left_chat)
	# Command: !fire 90
	GiftSingleton.add_command("fire", on_viewer_fire, 2, 2)
	GiftSingleton.add_alias("fire", "f")

	GiftSingleton.add_command("start", on_streamer_start, 1, 1, GiftSingleton.PermissionFlag.STREAMER)
	GiftSingleton.add_command("wait", on_streamer_wait, 0, 0, GiftSingleton.PermissionFlag.STREAMER)
	GiftSingleton.add_command("reset", on_streamer_reset, 0, 0, GiftSingleton.PermissionFlag.STREAMER)

	SignalBus.transparency_toggled.connect(on_transparency_toggled)

	change_state(GAME_STATE.WAITING)
	Transition.hide_transition()

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
#			join_next_round.visible = false
		GAME_STATE.RUNNING:
			waiting.visible = false
#			join_next_round.visible = true
		GAME_STATE.WINNER:
			pass
		GAME_STATE.PAUSED:
			pass

func next_round() -> void:
	change_state(GAME_STATE.RUNNING)

	for viewer in viewers_to_add:
		spawn_viewer(viewer)

	viewers_to_add.clear()

func reset() -> void:
	for viewer in Viewers.viewers:
		despawn_viewer(viewer)

	for viewer in Viewers.viewers:
		spawn_viewer(viewer)

func check_players_left() -> int:
	return viewers.keys().size()

func fire_viewer(viewer_name: String, angle: float, power: float) -> void:
	if not viewers.has(viewer_name): return

	# Send viewer
	var impulse: Vector2 = Vector2.RIGHT.rotated(-deg_to_rad(angle))
	print("Local impulse: ", impulse)
#	impulse = viewers[viewer_name].to_global(impulse)
#	print("Global impulse: ", impulse)
	impulse *= clamp(remap(power, 0.0, 100.0, 0.0, 4000.0), 0.0, 4000.0)
	viewers[viewer_name].call_deferred("apply_central_impulse", impulse)

func join_viewer(viewer_name: String) -> bool:
	if Viewers.is_viewer_joined(viewer_name):
		return false
	Viewers.add_viewer(viewer_name)
	return true

func spawn_viewer(viewer_name: String) -> void:
	var instance: RigidBody2D = player_scene.instantiate()
	instance.viewer_name = viewer_name
	viewer_container.call_deferred("add_child", instance)
	viewers[viewer_name] = instance
	await instance.ready
	instance.global_position = Vector2(randf_range(150, 1850), randf_range(100, 900))
	push_bullet(instance)

func despawn_viewer(viewer_name: String) -> void:
	if not Viewers.is_viewer_joined(viewer_name): return
	if not viewers.has(viewer_name): return
	viewers[viewer_name].queue_free()
	viewers.erase(viewer_name)

func push_bullet(obj: RigidBody2D) -> void:
	var push_vec: Vector2 = obj.global_transform.x.rotated(deg_to_rad(randi_range(0, 360)))
	push_vec *= 150.0
	obj.apply_central_impulse(push_vec)

func remove_viewer(viewer_name: String) -> void:
	if not Viewers.is_viewer_joined(viewer_name): return
	Viewers.remove_viewer(viewer_name)
	if not viewers.has(viewer_name): return
	viewers[viewer_name].queue_free()
	viewers.erase(viewer_name)

##### SIGNALS #####
func on_viewer_joined(viewer_name: String) -> void:
	if state != GAME_STATE.WAITING:
		viewers_to_add.append(viewer_name)
		join_viewer(viewer_name)
		return

	if not join_viewer(viewer_name): return
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

func on_streamer_start(cmd_info : CommandInfo, arg_arr : PackedStringArray) -> void:
	var countdown_duration: float = default_countdown
	if not arg_arr.is_empty():
		if arg_arr[0].is_valid_float():
			countdown_duration = float(arg_arr[0])
	countdown.start(countdown_duration)

func on_streamer_wait(cmd_info : CommandInfo) -> void:
	change_state(GAME_STATE.WAITING)

func on_streamer_reset(cmd_info : CommandInfo) -> void:
	reset()

func _on_countdown_finished() -> void:
	next_round()

func on_transparency_toggled(transparent: bool) -> void:
	for node in get_tree().get_nodes_in_group("Background"):
		node.visible = not transparent
		get_viewport().transparent_bg = transparent

func _on_death_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Players"): return

	print("KILLED: ", body.viewer_name)
	# TODO: Add a dead list
	despawn_viewer(body.viewer_name)

	if check_players_left() <= 1:
		# TODO: announce winner
		print("WINNER: ", viewers.keys()[0])
		reset()
