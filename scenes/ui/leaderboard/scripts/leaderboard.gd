extends VBoxContainer

@export var entry: PackedScene = preload("res://scenes/ui/leaderboard/leaderboard_entry.tscn")

var viewers_entries: Dictionary = {}

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func spawn_entry(viewer_name: String, score: int = 0) -> HBoxContainer:
	var instance = entry.instantiate()
	# TODO: add name and score
	
	add_child(instance)
	
	return instance

func despawn_entry(viewer_name: String) -> void:
	pass

func add_entry(viewer_name: String, score: int = 0) -> void:
	viewers_entries[viewer_name] = spawn_entry(viewer_name, score)

func delete_entry(viewer_name: String) -> void:
	pass
