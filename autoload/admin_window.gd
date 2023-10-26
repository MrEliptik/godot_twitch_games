extends Window

func _ready():
	hide()

func _process(delta):
	if Input.is_action_just_pressed("admin"):
		if visible:
			hide()
		else:
			show()
			
	if Input.is_action_just_pressed("enter"):
		pass

func _on_close_requested():
	hide()

func _on_send_btn_pressed():
	pass
