class_name UpgradeButton
extends Node2D


const SIZE := Vector2(48, 48)

# TODO: Pick better colors later.
const COLOR_MAXED := Color(1.0, 0.8, 0.2)
const COLOR_DIM := Color(0.5, 0.5, 0.5)
const COLOR_PROGRESS := Color(0.164, 1.0, 0.164, 1.0)
const COLOR_TRACK := Color(1.0, 1.0, 1.0, 0.502)

const RING_GAP := 5.0    
const RING_WIDTH := 5.0

const POLYGON_RADIUS := 34.0  
const CIRCLE_RADIUS := 30.0
const SQUARE_SIZE := 48.0
const CIRCLE_RING_SIDES := 64  

const POLYGON_START_ANGLE := -PI * 0.5
# From the foolish shapes scripts:
const COPIED_SHAPE_PROPERTIES := ["fill_color", "edge_width"]

signal hovered(item: ItemData)
signal unhovered(item: ItemData)
signal pressed_item(item: ItemData)

var item: ItemData   

var shape 

@onready var texture_button = %TextureButton


func _ready() -> void:
	_replace_shape()

	texture_button.flat = true
	texture_button.focus_mode = Control.FOCUS_NONE
	texture_button.size = SIZE
	texture_button.position = -SIZE * 0.5
	texture_button.icon = item.icon
	texture_button.expand_icon = true
	texture_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texture_button.add_theme_constant_override("icon_max_width", 28)
	texture_button.mouse_entered.connect(func(): hovered.emit(item))
	texture_button.mouse_exited.connect(func(): unhovered.emit(item))
	texture_button.pressed.connect(func(): pressed_item.emit(item))
	
	if texture_button.is_hovered():
		hovered.emit(item)


func refresh() -> void:
	visible = item.unlocked

	var color := Color.WHITE
	if item.is_maxed():
		color = COLOR_MAXED
	elif not SkillTreeUpgrades.can_buy(item):
		color = COLOR_DIM

	shape.edge_color = color
	texture_button.modulate.a = 0.5 if color == COLOR_DIM else 1.0
	queue_redraw()


func _draw() -> void:
	if item == null:
		return
	
	var outline := _outline_points()
	draw_polyline(outline, COLOR_TRACK, RING_WIDTH, true)
	
	var fraction := float(item.level) / float(maxi(item.max_level, 1))
	if fraction > 0.0:
		var color := COLOR_MAXED if item.is_maxed() else COLOR_PROGRESS
		draw_polyline(_partial_outline(outline, fraction), color, RING_WIDTH, true)

# Sets the shape of the button node.
func _replace_shape() -> void:
	var old_shape = get_node_or_null("%Shape")
	var new_shape = _create_shape()

	if old_shape != null:
		for property in COPIED_SHAPE_PROPERTIES:
			if property in old_shape and property in new_shape:
				new_shape.set(property, old_shape.get(property))
		add_child(new_shape)
		move_child(new_shape, old_shape.get_index())  
		new_shape.position = old_shape.position
		old_shape.queue_free()
	else:
		add_child(new_shape)
		move_child(new_shape, 0)

	shape = new_shape


func _create_shape():
	match item.shape_type:
		Enums.ShapeType.CIRCLE:
			var circle = FoolishShapes.instantiate_circle_shape()
			circle.radius = CIRCLE_RADIUS
			return circle
		Enums.ShapeType.PENTAGON:
			return _create_polygon(5)
		Enums.ShapeType.DIAMOND:
			return _create_polygon(4)
		_:  # SQUARE (the default)
			var square = FoolishShapes.instantiate_rectangle_shape()
			square.size = Vector2.ONE * SQUARE_SIZE
			square.anchor_ratio = Vector2(0.5, 0.5)
			return square


func _create_polygon(sides: int):
	var polygon = FoolishShapes.instantiate_polygon_shape()
	polygon.sides = sides
	polygon.radius = POLYGON_RADIUS
	return polygon


func _outline_points() -> PackedVector2Array:
	match item.shape_type:
		Enums.ShapeType.CIRCLE:
			return _polygon_outline(CIRCLE_RING_SIDES, CIRCLE_RADIUS)
		Enums.ShapeType.PENTAGON:
			return _polygon_outline(5, POLYGON_RADIUS)
		Enums.ShapeType.DIAMOND:
			return _polygon_outline(4, POLYGON_RADIUS)
		_:
			return _square_outline()


func _polygon_outline(sides: int, radius: float) -> PackedVector2Array:
	var ring_radius := radius + RING_GAP / cos(PI / sides)
	var points := PackedVector2Array()
	for i in sides + 1:
		var angle := POLYGON_START_ANGLE + TAU * i / sides
		points.append(Vector2.from_angle(angle) * ring_radius)
	return points


func _square_outline() -> PackedVector2Array:
	var h := SQUARE_SIZE * 0.5 + RING_GAP
	return PackedVector2Array([
		Vector2(0, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h), Vector2(-h, -h), Vector2(0, -h),
	])

func _partial_outline(points: PackedVector2Array, fraction: float) -> PackedVector2Array:
	var total := 0.0
	for i in points.size() - 1:
		total += points[i].distance_to(points[i + 1])

	var remaining := total * clampf(fraction, 0.0, 1.0)
	var result := PackedVector2Array([points[0]])
	for i in points.size() - 1:
		var segment := points[i].distance_to(points[i + 1])
		if remaining >= segment:
			result.append(points[i + 1])
			remaining -= segment
		else:
			result.append(points[i].lerp(points[i + 1], remaining / segment))
			break
	return result
