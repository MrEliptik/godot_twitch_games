extends Control

@export var entry: PackedScene = preload("res://scenes/ui/leaderboard_entry.tscn")

@onready var score_list: VBoxContainer = %Scorelist

func _ready():
	visible = false

func show_leaderboard(dict: Dictionary) -> void:
	var keys: Array = dict.keys()

	# Sort keys in descending order of values.
	keys.sort_custom(func(x: String, y: String) -> bool: return dict[x] > dict[y])
	
	# Remove entries before adding new ones
	for c in score_list.get_children():
		c.queue_free()
	
	# Add entries
	for k: String in keys:
		var entry_instance = entry.instantiate()
		score_list.add_child(entry_instance)
		entry_instance.display_entry(k, str(dict[k]))

func _on_exit_button_pressed():
	visible = false
