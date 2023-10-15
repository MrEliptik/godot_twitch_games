extends Node

var viewers: Array = []

func _ready():
	pass
#	GiftSingleton.viewer_joined.connect(on_viewer_joined)
#	GiftSingleton.viewer_left.connect(on_viewer_left)
	
func add_viewer(viewer_name: String) -> void:
	viewers.append(viewer_name)
	
func remove_viewer(viewer_name: String) -> void:
	viewers.erase(viewer_name)

func is_viewer_joined(viewer_name: String) -> bool:
	return viewer_name in viewers 
