extends Node

@export var selection_scene: PackedScene = preload("res://scenes/ui/selection.tscn")

# Private variable
var _params = null

# Call this instead to be able to provide arguments to the next scene
func change_scene(next_scene, transition: bool = false, params=null):
	if transition:
		Transition.show_transition()
		await Transition.done
	_params = params
	get_tree().change_scene_to_file(next_scene)

func change_scene_to(next_scene, transition: bool = false, params=null):
	if transition:
		Transition.show_transition()
		await Transition.done
	_params = params
	get_tree().change_scene_to_packed(next_scene)

# In the newly opened scene, you can get the parameters by name
func get_param(name):
	if _params != null and _params.has(name):
		return _params[name]
	return null
