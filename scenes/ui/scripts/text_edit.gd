extends TextEdit

@export var clear_icon: Texture = preload("res://icon.png")

var error_msg: String = "Sorry, but I'm afraid I can't do that, Dave."

func _ready() -> void:
	pass
		
func on_popup_menu_id_pressed(id: int) -> void:
	if id == 666:
		print("CLEAR")
		clear()

func _on_child_entered_tree(node: Node) -> void:
	if not node is PopupMenu: return
#		c.add_item("Clear", 666)
	node.add_item("Clear history", 666)
#	node.add_icon_item(clear_icon, "Clear history", 666)
#	node.set_item_icon_max_width(node.get_item_index(666), 20)
	node.id_pressed.connect(on_popup_menu_id_pressed)
