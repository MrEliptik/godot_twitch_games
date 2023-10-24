extends Control

@onready var grid_container = $GridContainer
@onready var status_value: Label = %StatusValue

# TODO: move to translation file later
var status_messages = {
	INIT = "init",
	AUTH_START = "authenticating...",
	CONNECTION_FAILED = "connection failed",
	CONNECTING = "connecting ...",
	CONNECTED = "connected"
}


func _ready() -> void:
	GiftSingleton.status.connect(on_status_changed)

	for c in grid_container.get_children():
		c.pressed.connect(on_btn_pressed.bind(c.scene))

func on_btn_pressed(scene: PackedScene) -> void:
	Transition.show_transition()
	await Transition.done
	get_tree().change_scene_to_packed(scene)

func on_status_changed(status_id: int) -> void:
	status_value.text = status_messages[GiftSingleton.STATUS.keys()[status_id]]
