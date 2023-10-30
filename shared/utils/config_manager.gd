class_name ConfigManager extends RefCounted


var config_file_name := "config.cfg"
var config_file_locations := [
	"res://" + config_file_name,
	"user://" + config_file_name,
]

var data: Variant
var error: bool = false

var allowed_config: Dictionary = {
	"twitch_auth": [
		"client_id",
		"client_secret",
		"initial_channel"
	]
}


func _init(load_config: bool = true) -> void:
	if load_config:
		read_configuration()


func create_configuration(config_data: Dictionary) -> void:
	var config := ConfigFile.new()

	for section in config_data:
		for key in config_data[section]:
			if not is_allowed(section, key):
				continue

			config.set_value(section, key, config_data[section][key])


	if OS.has_feature("editor"):
		config.save(config_file_locations[0])
	else:
		config.save(config_file_locations[1])


func is_allowed(section: String, key: String) -> bool:
	return allowed_config.has(section) && allowed_config[section].has(key)



func read_configuration() -> bool:
	for location in config_file_locations:
		data = load_config_file(location)
		if not data.has("error"):
			break

	if data.has("error"):
		data = null
		return false

	return true


func load_config_file(file: String) -> Dictionary:
	var config := ConfigFile.new()
	if config.load(file) != OK:
		return {
			"error": true
		}

	var config_dict: Dictionary = {}
	for section in config.get_sections():
		# prints("section", section)
		config_dict[section] = {}
		for key in config.get_section_keys(section):
			config_dict[section][key] = config.get_value(section, key)

	return config_dict
