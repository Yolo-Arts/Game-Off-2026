extends Node2D

const EDGE := 175.0
const FAN := deg_to_rad(40.0)

@export var button_scene: PackedScene

@onready var pivot = %Pivot
@onready var lines_root = %Lines
@onready var buttons_root = %Buttons
@onready var description_view: UpgradeDescriptionView = %UpgradeDescriptorView

# Holds the position of centers. A dictionary of ItemData and Vector2
var _centers := {}
# Holds the button nodes. A dictionary of ItemData and upgrade_button.tscn (button_scene)
var _buttons := {}
# An array of Dictionaries. Holds the foolish shape line, with the respective item data node.
# {"node": LineShape, "child": ItemData}
var _lines: Array[Dictionary] = [] 

func _ready() -> void:
	pivot.position = get_viewport_rect().size * 0.5
	var roots: Array = SkillTreeUpgrades.TREE
	
	for i in roots.size():
		var dir := Vector2.UP.rotated(i * TAU / roots.size())
		_layout(roots[i], null, Vector2.ZERO, dir)
	
	for item in _centers:
		item.try_unlock()
	
	_build_visuals()

	# TODO: remove these lines when actual currency system is added (from playing game)
	Currencies.add(Enums.CurrencyType.GEAR, 100)
	Currencies.add(Enums.CurrencyType.STAR, 500)

	SkillTreeUpgrades.changed.connect(_refresh)
	Currencies.changed.connect(_refresh)
	_refresh()

# Handles zooming and panning.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pivot.position += event.relative
	elif event is InputEventMouseButton and event.pressed:
		var f := 1.0
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: f = 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: f = 1.0 / 1.1
		if f != 1.0:
			var new_scale := clampf(pivot.scale.x * f, 0.8, 1.5)
			var real = new_scale / pivot.scale.x
			var m := get_local_mouse_position()
			pivot.position = m + (pivot.position - m) * real
			pivot.scale = Vector2.ONE * new_scale

# populates _centers 
func _layout(entry: Array, parent: ItemData, parent_pos: Vector2, dir: Vector2) -> void:
	var item := load(SkillTreeUpgrades.ITEM_PATH % entry[0]) as ItemData
	var is_new := not _centers.has(item)
	
	if is_new:
		item.parents.clear()
		item.children.clear()
		item.unlocked = false
	
	if parent and not parent.children.has(item):
		parent.children.append(item)
		item.parents.append(parent)
	
	if not is_new:
		if parent and item.parents.size() >= 2:
			var wanted := parent_pos + dir * EDGE
			var pts := _circle_intersections(_centers[item.parents[0]], parent_pos, EDGE)
			if not pts.is_empty():
				pts.sort_custom(func(a, b): return a.distance_to(wanted) < b.distance_to(wanted))
				_shift(item, pts[0] - _centers[item])
		return
	
	var pos := parent_pos + dir * EDGE
	_centers[item] = pos
	
	if entry.size() > 1:
		var kids: Array = entry[1]
		for i in kids.size():
			var spread := (i - (kids.size() - 1) / 2.0) * FAN
			_layout(kids[i], item, pos, dir.rotated(spread))

# some math to deal with radial skill trees.
func _circle_intersections(a: Vector2, b: Vector2, r: float) -> Array[Vector2]:
	var d := a.distance_to(b)
	if d == 0.0 or d > 2.0 * r:
		return []
	var h := sqrt(r * r - d * d / 4.0)
	var perp := (b - a).orthogonal().normalized()
	var mid := (a + b) * 0.5
	return [mid + perp * h, mid - perp * h]


func _shift(item: ItemData, delta: Vector2) -> void:
	_centers[item] += delta
	for c in item.children:
		_shift(c, delta)

# populates _buttons
func _build_visuals() -> void:
	var hub := FoolishShapes.instantiate_circle_shape()
	hub.radius = 30.0
	buttons_root.add_child(hub)
	
	for item in _centers:
		var btn := button_scene.instantiate() as UpgradeButton
		btn.item = item
		btn.position = _centers[item]
		_buttons[item] = btn
		btn.hovered.connect(_on_item_hovered)
		btn.unhovered.connect(_on_item_unhovered)
		btn.pressed_item.connect(_on_item_pressed)
		
		buttons_root.add_child(btn)
		
		if item.parents.is_empty():
			_add_line(Vector2.ZERO, _centers[item], item)
		for p in item.parents:
			_add_line(_centers[p], _centers[item], item)


func _add_line(from: Vector2, to: Vector2, child: ItemData) -> void:
	var line := FoolishShapes.instantiate_line_shape()
	line.draw_mode = LineShape.LineDrawMode.START_AND_END_POINT
	line.start_point = from
	line.end_point = to
	line.edge_color = Color(0.7, 0.7, 0.7)
	lines_root.add_child(line)
	_lines.append({"node": line, "child": child})


func _refresh() -> void:
	for item in _buttons:
		_buttons[item].refresh()
	for line in _lines:
		line["node"].visible = line["child"].unlocked


func _on_item_hovered(item: ItemData) -> void:
	_buttons[item].z_index = 20  # draw the hovered button above the description view
	description_view.show_for(item, _buttons[item].global_position)


func _on_item_unhovered(item: ItemData) -> void:
	_buttons[item].z_index = 0
	description_view.hide_for(item)


func _on_item_pressed(item: ItemData) -> void:
	if item.is_maxed():
		return
	if SkillTreeUpgrades.buy(item):
		description_view.play_buy()
	else:
		description_view.play_cannot_buy()
