class_name ConfigManager extends RefCounted

var config: ConfigFile
var config_file_name := "config.cfg"
var config_file_path: String
var config_file_locations := [
	"res://" + config_file_name,
	"user://" + config_file_name,
]

var data: Variant
var error: bool = false

## on config creation only allow these keys to be set
var allowed_start_config: Dictionary = {
	"twitch_auth": [
		"client_id",
		"client_secret",
		"initial_channel"
	]
}


func _init(load_config: bool = true) -> void:
	if load_config:
		_read_config()


##
## public
##


## get full config data
func get_config() -> Dictionary:
	return data


## get data from section
func get_section(section: String) -> Dictionary:
	if data.has(section):
		return data[section]

	return {}


## set data in section
func set_config_section(config_data: Dictionary, section: String) -> void:
	_update_config(config_data, section)


## creates a new configuration file
func create_configuration(config_data: Dictionary) -> void:
	config = ConfigFile.new()

	for section in config_data:
		for key in config_data[section]:
			if not allowed_start_config.has(section) && allowed_start_config[section].has(key):
				continue

			config.set_value(section, key, config_data[section][key])

	if OS.has_feature("editor"):
		_save(config_file_locations[0])
	else:
		_save(config_file_locations[1])


##
## private
##


## finds the first config file that exists and loads it
func _read_config() -> bool:
	for location in config_file_locations:
		data = _load_config_file(location)
		if not data.has("error"):
			config_file_path = location
			break

	if data.has("error"):
		data = null
		return false

	return true


## update the config file with new data
func _update_config(config_data: Dictionary, section: String) -> void:
	for key in config_data:
		config.set_value(section, key, config_data[key])

	_save()
	data = _config_to_dictionary()


## loads a config file and returns the data
func _load_config_file(file: String) -> Dictionary:
	config = ConfigFile.new()
	if config.load(file) != OK:
		return {
			"error": true
		}

	return _config_to_dictionary()


## save config
func _save(file_path: String = config_file_path) -> void:
	config.save(file_path)


## create dictionary from config
func _config_to_dictionary() -> Dictionary:
	var config_dict: Dictionary = {}
	for section in config.get_sections():
		config_dict[section] = {}
		for key in config.get_section_keys(section):
			config_dict[section][key] = config.get_value(section, key)

	return config_dict
