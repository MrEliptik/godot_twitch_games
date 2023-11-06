class_name ConfigManager extends RefCounted

var config: ConfigFile
var config_file_name := "config.cfg"
var found_file_location: String
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
		_read_configuration()


##
## public
##


func create_configuration(config_data: Dictionary) -> void:
	config = ConfigFile.new()

	for section in config_data:
		for key in config_data[section]:
			if not _is_allowed(section, key):
				continue

			config.set_value(section, key, config_data[section][key])

	_save()


##
## private
##


func _save() -> void:
	if OS.has_feature("editor"):
		config.save(config_file_locations[0])
	else:
		config.save(config_file_locations[1])


func _is_allowed(section: String, key: String) -> bool:
	return allowed_config.has(section) && allowed_config[section].has(key)


func _read_configuration() -> bool:
	for location in config_file_locations:
		data = _load_config_file(location)
		if not data.has("error"):
			found_file_location = location
			break

	if data.has("error"):
		data = null
		return false

	return true


func _load_config_file(file: String) -> Dictionary:
	config = ConfigFile.new()
	if config.load(file) != OK:
		return {
			"error": true
		}

	var config_dict: Dictionary = {}
	for section in config.get_sections():
		config_dict[section] = {}
		for key in config.get_section_keys(section):
			config_dict[section][key] = config.get_value(section, key)

	return config_dict
