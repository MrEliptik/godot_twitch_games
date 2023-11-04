extends Label

signal finished()

var tween: Tween
var tween_count: Tween

func _ready() -> void:
	visible = true
	modulate.a = 0.0

func _process(delta: float) -> void:
	pass

func start(duration: float) -> void:
	if tween_count and tween_count.is_running():
		tween_count.kill()
	tween_count = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween_count.tween_method(count_down, duration, 0.0, duration)
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	for i in range(int(duration)):
		tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(self, "scale", Vector2.ONE, 0.5)
		tween.tween_interval(0.4)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(emit_signal.bind("finished"))
	
	await get_tree().create_timer(duration).timeout

func count_down(value: float) -> void:
	text = "STARTS IN\n" + str(ceil(value))
