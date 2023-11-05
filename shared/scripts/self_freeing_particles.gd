extends GPUParticles2D

var color: Color = Color.WHITE

func _ready() -> void:
	modulate = color
	
	var max_lifetime: float = lifetime / speed_scale
	emitting = true

	for child in get_children():
		if not child is GPUParticles2D: continue
		var child_lifetime: float = (child.lifetime / child.speed_scale)
		if  child_lifetime > max_lifetime:
			max_lifetime = child_lifetime
		child.emitting = true
	
	# TODO: remove when we can use the signal finished
	max_lifetime *= 4
	
	var timer = get_tree().create_timer(max_lifetime)
	timer.timeout.connect(on_timer_timeout)

func set_shape(extents: Vector2) -> void:
	process_material.emission_box_extents = Vector3(extents.x, extents.y, 0.0)
	for child in get_children():
		if not child is GPUParticles2D: continue
		child.process_material.emission_box_extents = Vector3(extents.x, extents.y, 0.0)

func on_timer_timeout() -> void:
	queue_free()
