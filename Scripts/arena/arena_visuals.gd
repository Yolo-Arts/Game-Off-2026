@tool
extends Polygon2D
class_name ArenaVisuals

@export_range(3, 64) var point_count : int
@export_range(1.0, 20000.0) var radius : float 
@export var colour_cycle_speed : float = 1.0
@export var border : Line2D
@export var collider : CollisionPolygon2D
@export var turret_paths : Array[Path2D] = []

func _ready() -> void:
	generate_shape(point_count, radius)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		generate_shape(point_count, radius)


func generate_shape(count : int, r : float) -> void:
	point_count = count
	radius = r
	
	var poly : Array[Vector2] = []
	var uvs : Array[Vector2] = []
	var arc : float = (2 * PI) / count
	
	for i in range(count):
		var v := Vector2.RIGHT.rotated(i * arc) * radius
		poly.append(v)
	
	var origin = Vector2(0.0, 0.0)
	for point in poly:
		uvs.append(point - origin)
	
	if border != null:
		border.clear_points()
		for point in poly:
			border.add_point(point)
	
	if collider != null:
		collider.set_polygon(poly)
	
	if turret_paths.size() == 2:
		turret_paths[0].curve.clear_points()
		turret_paths[1].curve.clear_points()
		for i in range(poly.size()):
			var j = poly.size() - (i + 1)
			turret_paths[0].curve.add_point(poly[i])
			turret_paths[1].curve.add_point(poly[j])
		turret_paths[0].curve.add_point(poly[0])
		turret_paths[1].curve.add_point(poly[poly.size() - 1])
	
	set_polygon(poly)
	set_uv(uvs)
	
