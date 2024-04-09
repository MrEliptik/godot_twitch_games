extends Control

@onready var entry = load("res://scenes/ui/leaderboard_entry.tscn")

@onready var score_list = %Scorelist

func _ready():
	visible = false

func show_leaderboard(dict: Dictionary) -> void:
	var keys: Array = dict.keys()

	# Sort keys in descending order of values.
	keys.sort_custom(func(x: String, y: String) -> bool: return dict[x] > dict[y])

	for k: String in keys:
		var entry_instance = entry.instantiate()
		score_list.add_child(entry_instance)
		entry_instance.display_entry(k, str(dict[k]))

func _on_exit_button_pressed():
	visible = false
