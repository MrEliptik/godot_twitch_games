class_name GamesManager extends RefCounted

var games_path = "res://scenes/games"
var game_icon_name = "game_icon.png"
var game_config_name = "game.cfg"

var games = []


func get_games() -> Array:
	var dir := DirAccess.open(games_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var index: int = 0
		while file_name != "":
			if dir.current_is_dir() && !file_name.begins_with("_"):
				index += 1
				var config: Dictionary = load_config(file_name)

				if !config.has("name"):
					config["name"] = file_name

				if !config.has("order"):
					config["order"] = index * 100

				var icon = load_icon(file_name)
				if icon:
					config["icon"] = icon

				config["scene_path"] = games_path + "/" + file_name + "/" + file_name + ".tscn"

				games.append(config)
			file_name = dir.get_next()
	else:
		print("GamesManager ERROR: Games directory not found")

	games.sort_custom(sort_by_order)
	games.map(delete_order)

	return games


func load_icon(game_name: String) -> ImageTexture:
	var icon_path: String = games_path + "/" + game_name + "/" + game_icon_name
	var has_resource = ResourceLoader.exists(icon_path, "CompressedTexture2D")
	if !has_resource:
		return null

	return ResourceLoader.load(icon_path, "CompressedTexture2D")

func load_config(game_name: String) -> Dictionary:
	var file: String = games_path + "/" + game_name + "/" + game_config_name
	var config := ConfigFile.new()
	if config.load(file) != OK:
		return {}

	var config_dict: Dictionary = {}
	for section in config.get_sections():
		for key in config.get_section_keys(section):
			config_dict[key] = config.get_value(section, key)

	return config_dict

func sort_by_order(a: Dictionary, b: Dictionary) -> bool:
	return a.order < b.order

func delete_order(dict: Dictionary) -> Dictionary:
	if dict.has("order"):
		dict.erase("order")

	return dict
