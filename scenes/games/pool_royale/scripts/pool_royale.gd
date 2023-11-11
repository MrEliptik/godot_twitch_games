extends Node2D

enum GAME_STATE {WAITING, RUNNING, WINNER, PAUSED}

@export var player_scene: PackedScene = preload("res://scenes/games/pool_royale/player.tscn")
@export var default_countdown: float = 3.0

var state: GAME_STATE = GAME_STATE.WAITING

@onready var viewer_container: Node2D = $ViewerContainer
@onready var waiting: Label = $CanvasLayer/Waiting
@onready var countdown: Label = $CanvasLayer/Countdown

var viewer_avatars: Dictionary = {}

func _ready() -> void:
	Viewers.viewer_active.connect(on_viewer_active)
	Viewers.viewer_waiting.connect(on_viewer_waiting)
	Viewers.viewer_dead.connect(on_viewer_dead)
	Viewers.last_viewer_active.connect(on_last_viewer_active)
	Viewers.viewer_removed.connect(on_viewer_removed)
	Viewers.viewers_reset.connect(on_viewers_reset)
	
	GameConfigManager.load_config()

	# Command: !fire 90
	GiftSingleton.add_command("fire", on_viewer_fire, 2, 2)
	GiftSingleton.add_alias("fire", "f")

	GiftSingleton.add_command("start", on_streamer_start, 1, 1, GiftSingleton.PermissionFlag.STREAMER)
	GiftSingleton.add_command("wait", on_streamer_wait, 0, 0, GiftSingleton.PermissionFlag.STREAMER)

	SignalBus.transparency_toggled.connect(on_transparency_toggled)

	change_state(GAME_STATE.WAITING)
	Transition.hide_transition()

func _process(_delta: float) -> void:
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
			Viewers.open()
			Viewers.unlock()
		GAME_STATE.RUNNING:
			waiting.visible = false
			Viewers.lock()
		GAME_STATE.WINNER:
			waiting.visible = false
			Viewers.lock()
		GAME_STATE.PAUSED:
			waiting.visible = false
			Viewers.lock()

func fire_viewer(viewer_name: String, angle: float, power: float) -> void:
	if not Viewers.is_active(viewer_name): return

	var impulse: Vector2 = Vector2.RIGHT.rotated(-deg_to_rad(angle))
	impulse *= clamp(remap(power, 0.0, 100.0, 0.0, 4000.0), 0.0, 4000.0)
	viewer_avatars[viewer_name].call_deferred("apply_central_impulse", impulse)

func spawn_viewer(viewer_name: String) -> void:
	if viewer_avatars.has(viewer_name): return

	var instance: RigidBody2D = player_scene.instantiate()
	instance.viewer_name = viewer_name
	viewer_container.call_deferred("add_child", instance)
	viewer_avatars[viewer_name] = instance
	await instance.ready
	instance.global_position = Vector2(randf_range(150, 1850), randf_range(100, 900))
	push_bullet(instance)

func despawn_viewer(viewer_name: String) -> void:
	if not viewer_avatars.has(viewer_name): return
	viewer_avatars[viewer_name].queue_free()
	viewer_avatars.erase(viewer_name)

func push_bullet(obj: RigidBody2D) -> void:
	var push_vec: Vector2 = obj.global_transform.x.rotated(deg_to_rad(randi_range(0, 360)))
	push_vec *= 150.0
	obj.apply_central_impulse(push_vec)

##### SIGNALS #####

func on_viewer_active(viewer_name: String) -> void:
	spawn_viewer(viewer_name)

func on_viewer_waiting(viewer_name: String) -> void:
	despawn_viewer(viewer_name)

func on_viewer_dead(viewer_name: String) -> void:
	despawn_viewer(viewer_name)

func on_viewer_removed(viewer_name: String) -> void:
	despawn_viewer(viewer_name)

func on_viewers_reset() -> void:
	change_state(GAME_STATE.WAITING)

func on_last_viewer_active() -> void:
	change_state(GAME_STATE.WINNER)

func _on_countdown_finished() -> void:
	change_state(GAME_STATE.RUNNING)

func on_transparency_toggled(transparent: bool) -> void:
	for node in get_tree().get_nodes_in_group("Background"):
		node.visible = not transparent
		get_viewport().transparent_bg = transparent

func _on_death_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Players"): return
	Viewers.dead(body.viewer_name)

	#if Viewers.count_active() == 1:
	#	# TODO: announce winner
	#	print("WINNER: ", viewer_container.keys()[0])
	#	Viewers.reset()

##### COMMANDS #####

func on_viewer_fire(cmd_info : CommandInfo, arg_arr : PackedStringArray) -> void:
	if state != GAME_STATE.RUNNING: return
	if not arg_arr[0].is_valid_float(): return
	if not arg_arr[1].is_valid_float(): return

	var angle: float = float(arg_arr[0])
	var power: float = float(arg_arr[1])
	fire_viewer(cmd_info.sender_data.tags["display-name"], angle, power)

func on_streamer_start(_cmd_info : CommandInfo, arg_arr : PackedStringArray) -> void:
	var countdown_duration: float = default_countdown
	if not arg_arr.is_empty():
		if arg_arr[0].is_valid_float():
			countdown_duration = float(arg_arr[0])
	countdown.start(countdown_duration)

func on_streamer_wait(_cmd_info : CommandInfo) -> void:
	change_state(GAME_STATE.WAITING)



