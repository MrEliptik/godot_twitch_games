extends Control

@onready var button_container = %ButtonContainer
@onready var status_value: Label = %StatusValue
@onready var version_btn: LinkButton = $VersionBtn
@onready var games: Array = GamesManager.new().get_games()
@onready var update_checker := UpdateChecker.new()

var button_scene = preload("res://scenes/ui/selection_button.tscn")

# TODO: move to translation file later
var status_messages = {
	INIT = "init",
	AUTH_START = "authenticating...",
	AUTH_FILE_NOT_FOUND = "application config file not found",
	CONNECTION_FAILED = "connection failed",
	CONNECTING = "connecting ...",
	CONNECTED = "connected"
}

func _ready() -> void:
	GameConfigManager.load_config()
	Viewers.close()

	add_child(update_checker)
	update_checker.get_latest_version()
	update_checker.release_parsed.connect(on_released_parsed)

	GiftSingleton.status.connect(on_status_changed)

	# when we connect to late to get the last status, we pull the last status that was emited
	if GiftSingleton.last_status != GiftSingleton.STATUS.NONE:
		on_status_changed(GiftSingleton.last_status)

	# delete buttons - we need them only for layouting
	for c in button_container.get_children():
		c.queue_free()

	for game_config in games:
		var game_button = button_scene.instantiate()
		game_button.game_name = game_config.name
		game_button.scene_path = game_config.scene_path
		game_button.icon_texture = game_config.icon if game_config.has("icon") else null
		button_container.add_child(game_button)

		game_button.pressed.connect(on_btn_pressed.bind(game_button.scene))

	Transition.hide_transition()

func on_btn_pressed(scene: PackedScene) -> void:
	GameConfigManager.save_config()

	Transition.show_transition()
	await Transition.done
	get_tree().change_scene_to_packed(scene)

func on_status_changed(status_id: int) -> void:
	status_value.text = status_messages[GiftSingleton.STATUS.keys()[status_id]]

func on_released_parsed(release: Dictionary) -> void:
	print("release: ", release["version"])

	if release["new"]:
		version_btn.text = "New version available: " + release["version"]
	else:
		version_btn.text = "You have the latest version: " + release["version"]
	version_btn.uri = release["url"]
