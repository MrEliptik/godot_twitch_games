extends Control

func _ready():
	pass

func _on_gift_viewer_join(name):
	var instance = $Label.duplicate()
	add_child(instance)
	instance.position = Vector2(randi_range(0, 1920), randi_range(0, 1080))
	instance.text = name
