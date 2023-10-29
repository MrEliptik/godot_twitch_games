extends Button

@export var game_name: String = "Game name"
@export var scene: PackedScene = preload("res://scenes/games/marble_race/marble_race.tscn")

var tween: Tween

func _ready():
	$Label.text = game_name

func focus_on() -> void:
	pivot_offset = size / 2.0
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)

func focus_off() -> void:
	pivot_offset = size / 2.0
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)

func _on_mouse_entered():
	focus_on()

func _on_mouse_exited():
	focus_off()

func _on_focus_entered():
	focus_on()

func _on_focus_exited():
	focus_off()
