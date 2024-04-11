extends PanelContainer

@onready var name_label = $HBoxContainer/NameLabel
@onready var score_label = $HBoxContainer/ScoreLabel

func display_entry(name, score):
	name_label.text = name
	score_label.text = score
