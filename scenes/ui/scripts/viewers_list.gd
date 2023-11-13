extends ItemList

enum TYPE { ACTIVE, WAITING, DEAD }


@export var list_type:TYPE = TYPE.WAITING

func _ready() -> void:
	clear()

	if !Viewers:
		return

	if list_type == TYPE.WAITING:
		for viewer in Viewers.viewers_waiting:
			add_item(viewer)

		Viewers.viewer_waiting.connect(on_add_waiting)
		Viewers.viewer_active.connect(on_remove_waiting)
		Viewers.viewer_dead.connect(on_remove_waiting)

	elif list_type == TYPE.ACTIVE:
		for viewer in Viewers.viewers_active:
			add_item(viewer)

		Viewers.viewer_waiting.connect(on_remove_waiting)
		Viewers.viewer_active.connect(on_add_waiting)
		Viewers.viewer_dead.connect(on_remove_waiting)

	elif list_type == TYPE.DEAD:
		for viewer in Viewers.viewers_dead:
			add_item(viewer)

		Viewers.viewer_waiting.connect(on_remove_waiting)
		Viewers.viewer_active.connect(on_remove_waiting)
		Viewers.viewer_dead.connect(on_add_waiting)

	Viewers.viewer_removed.connect(on_remove_waiting)


func on_add_waiting(viewer_name: String) -> void:
	if get_viewer_idx(viewer_name) > -1:
		return

	add_item(viewer_name)


func on_remove_waiting(viewer_name: String) -> void:
	var index: int = get_viewer_idx(viewer_name)

	if index == -1:
		return

	remove_item(index)


func get_viewer_idx(viewer_name: String) -> int:
	for i in get_item_count():
		if get_item_text(i) == viewer_name:
			return i

	return -1
