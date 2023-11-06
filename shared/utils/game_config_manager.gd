class_name GameConfigManager extends ConfigManager

# TODO: add more configs like transparent, fullscreen etc
#       find a way to automatically call game_config_manager.save_config() (connect close event mavbe)

var game: Node
var game_name: String

var allowed_game_config: Array[String] = [
	"window_position",
	"window_size"
]


func _init(node: Node) -> void:
	game = node
	game_name = game.get_tree().current_scene.scene_file_path.get_file().get_basename()

	_read_configuration()
	_apply_config()


##
## public
##


func get_config() -> Dictionary:
	if data.has(game_name):
		return data[game_name]

	return {}


func save_config() -> void:
	var updated_config : Dictionary = {}

	for key in allowed_game_config:
		updated_config[key] = call("get_%s" % key)

	_update_config(updated_config)


##
## private
##


func _update_config(config_data) -> void:
	for key in config_data:
		if not allowed_game_config.has(key):
			continue

		config.set_value(game_name, key, config_data[key])

	_save()


func _apply_config() -> void:
	if not data.has(game_name):
		return

	for key in data[game_name]:
		call("set_%s" % key, data[game_name][key])


func _save() -> void:
	config.save(found_file_location)


##
## config functions
##


func set_window_position(pos: Vector2) -> void:
	game.get_window().position = pos


func get_window_position() -> Vector2:
	return game.get_window().position


func set_window_size(size: Vector2) -> void:
	game.get_window().size = size


func get_window_size() -> Vector2:
	return game.get_window().size
