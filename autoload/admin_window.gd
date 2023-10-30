extends Window

@onready var text_edit: TextEdit = $Control/MarginContainer/VBoxContainer/TextEdit
@onready var line_edit: LineEdit = $Control/MarginContainer/VBoxContainer/HBoxContainer/LineEdit

func _ready():
	hide()

func _process(delta):
	if Input.is_action_just_pressed("admin"):
		if visible:
			hide()
			line_edit.release_focus()
		else:
			show()
			line_edit.grab_focus()
			
	if Input.is_action_just_pressed("enter"):
		send()

func autocomplete(typed: String) -> void:
	var command_dict: Dictionary = {}
	
	for key in command_dict.keys():
		# pou "poured, froum"
		if typed in command_dict[key]:
			# TODO: count how much in common with typed
			pass
			
	return 

func send() -> void:
	var content: String = line_edit.text
	line_edit.text = ""
	text_edit.insert_line_at(text_edit.get_line_count()-1, content)
	
	# TODO: call command singleton with the content and listen to response

## SIGNALS
func _on_close_requested():
	hide()
	line_edit.release_focus()

func _on_send_btn_pressed():
	send()

