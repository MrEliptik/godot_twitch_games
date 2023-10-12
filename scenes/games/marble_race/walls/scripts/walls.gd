extends StaticBody2D

@onready var path: Path2D = $Path2D
@onready var line: Line2D = $Line2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	line.points = path.curve.get_baked_points()
	collision_polygon.polygon = line.points
