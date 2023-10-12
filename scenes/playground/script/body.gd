extends StaticBody2D

@onready var polygon: Polygon2D = $Polygon2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

func _ready():
	collision_polygon.polygon = polygon.polygon
