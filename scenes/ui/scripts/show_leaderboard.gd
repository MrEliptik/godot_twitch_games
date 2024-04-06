extends Control

@onready var leaderboard_tile = load("res://scenes/ui/leaderboard_tile.tscn")

func _ready():
	show_leaderboard(Leaderboard.list)

func show_leaderboard(dict: Dictionary) -> void:
	var keys: Array = dict.keys()

	# Sort keys in descending order of values.
	keys.sort_custom(func(x: String, y: String) -> bool: return dict[x] > dict[y])

	for k: String in keys:
		var top_tile = leaderboard_tile.instantiate()
		get_node("OuterMarginContainer/VBoxContainer/PanelMarginContainer/ContentPanelContainer/VBoxContainer/ListContainer/PanelContainer/HBoxContainer/TopList").add_child(top_tile)
		top_tile.get_node("Label").text = k
		
		var list_tile = leaderboard_tile.instantiate()
		get_node("OuterMarginContainer/VBoxContainer/PanelMarginContainer/ContentPanelContainer/VBoxContainer/ListContainer/PanelContainer/HBoxContainer/ScoreList").add_child(list_tile)
		list_tile.get_node("Label").text = str(dict[k])
