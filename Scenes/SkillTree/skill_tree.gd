extends Node2D

signal closed

const EDGE := 200.0
const FAN := deg_to_rad(35.0)

const INTRO_ANIMATION_DELAYS := 0.18
const OUTRO_ANIMATION_DELAYS := 0.07  
const LINE_GROW_TIME := 0.25
const LINE_HINT_LENGTH := 95.0 
const LINE_HINT_PULSE := 10.0 
const LINE_COLOR := Color(1.0, 1.0, 1.0, 1.0)

enum LineState { HIDDEN, HINT, FULL }

@export var button_scene: PackedScene

@onready var pivot = %Pivot
@onready var lines_root = %Lines
@onready var buttons_root = %Buttons
@onready var description_view: UpgradeDescriptionView = %UpgradeDescriptorView

# Holds the position of centers. A dictionary of ItemData and Vector2
var centers := {}
# Holds the button nodes. A dictionary of ItemData and upgrade_button.tscn (button_scene)
var buttons := {}
# An array of Dictionaries. Holds the foolish shape line, with the respective item data node.
# {"node": LineShape, "child": ItemData}
var _lines: Array[Dictionary] = [] 

var _hub
# Dictionary[ItemData, int]
var _depth := {}
var _max_depth := 1
var _shown := {}
var _hovered_item: ItemData
var intro_outro_animation_playing: bool = true
var _is_closing: bool = false

func _ready() -> void:
	pivot.position = get_viewport_rect().size * 0.5
	var roots: Array = SkillTreeUpgrades.TREE
	
	for i in roots.size():
		var dir := Vector2.UP.rotated(i * TAU / roots.size())
		_layout(roots[i], null, Vector2.ZERO, dir)
	
	#for item in centers:
		#item.try_unlock()
	
	_compute_depths()
	_build_visuals()
	
	# TODO: remove these lines when actual currency system is added (from playing game)
	#Currencies.add(Enums.CurrencyType.GEAR, 100)
	#Currencies.add(Enums.CurrencyType.STAR, 5)

	SkillTreeUpgrades.changed.connect(_refresh)
	Currencies.changed.connect(_refresh)
	_refresh()
	_play_intro()

# Handles zooming and panning.
func _unhandled_input(event: InputEvent) -> void:
	if intro_outro_animation_playing:
		return
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

# populates centers 
func _layout(entry: Array, parent: ItemData, parent_pos: Vector2, dir: Vector2) -> void:
	#var item := load(SkillTreeUpgrades.ITEM_PATH % entry[0]) as ItemData
	
	var item = SkillTreeUpgrades.get_item(entry[0])
	if item == null:
		return
	
	var is_new := not centers.has(item)
	
	#if is_new:
		#item.parents.clear()
		#item.children.clear()
		#item.unlocked = false
	
	#if parent and not parent.children.has(item):
		#parent.children.append(item)
		#item.parents.append(parent)
	
	if not is_new:
		if parent and item.parents.size() >= 2:
			var wanted := parent_pos + dir * EDGE
			var pts := _circle_intersections(centers[item.parents[0]], parent_pos, EDGE)
			if not pts.is_empty():
				pts.sort_custom(func(a, b): return a.distance_to(wanted) < b.distance_to(wanted))
				_shift(item, pts[0] - centers[item])
		return
	
	var pos := parent_pos + dir * EDGE
	centers[item] = pos
	
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
	centers[item] += delta
	for c in item.children:
		_shift(c, delta)

# populates buttons
func _build_visuals() -> void:
	_hub = FoolishShapes.instantiate_circle_shape()
	_hub.radius = 30.0
	buttons_root.add_child(_hub)
	
	for item in centers:
		var btn := button_scene.instantiate() as UpgradeButton
		btn.item = item
		btn.position = centers[item]
		buttons[item] = btn
		btn.hovered.connect(_on_item_hovered)
		btn.unhovered.connect(_on_item_unhovered)
		btn.pressed_item.connect(_on_item_pressed)
		
		buttons_root.add_child(btn)
		
		if item.parents.is_empty():
			_add_line(Vector2.ZERO, centers[item], item, null)
		for p in item.parents:
			_add_line(centers[p], centers[item], item, p)


func _add_line(from: Vector2, to: Vector2, child: ItemData, parent: ItemData) -> void:
	var line := FoolishShapes.instantiate_line_shape()
	line.draw_mode = LineShape.LineDrawMode.START_AND_END_POINT
	line.start_point = from
	line.end_point = to
	line.edge_color = LINE_COLOR
	line.visible = false
	lines_root.add_child(line)
	_lines.append({
		"node": line, "child": child, "parent": parent, "from": from, "to": to,
		"state": LineState.HIDDEN, "tween": null, "pulse": null,
	})


func _refresh() -> void:
	for item in buttons:
		buttons[item].refresh()
	if intro_outro_animation_playing:
		return  # the intro / close animation is playing, the intro syncs everything once it is done
	_sync_unlocks()


func _on_item_hovered(item: ItemData) -> void:
	_hovered_item = item
	buttons[item].z_index = 20  # draw the hovered button above the description view
	description_view.show_for(item, buttons[item].global_position)


func _on_item_unhovered(item: ItemData) -> void:
	if _hovered_item == item:
		_hovered_item = null
	buttons[item].z_index = 0
	description_view.hide_for(item)


func _on_item_pressed(item: ItemData) -> void:
	if intro_outro_animation_playing or item.is_maxed():
		return
	if SkillTreeUpgrades.buy(item):
		description_view.play_buy()
	else:
		description_view.play_cannot_buy()


# ---------------------------------------------------------------------------------------------
# Animations
# ---------------------------------------------------------------------------------------------

# Works out how many steps each item is away from the middle (the roots are 1).
# Merge nodes use the shortest way to them.
func _compute_depths() -> void:
	var queue: Array[ItemData] = []
	for entry in SkillTreeUpgrades.TREE:
		var root: ItemData = SkillTreeUpgrades.get_item(entry[0])
		if root != null and not _depth.has(root):
			_depth[root] = 1
			queue.append(root)

	while not queue.is_empty():
		var item: ItemData = queue.pop_front()
		for child in item.children:
			if not _depth.has(child):
				_depth[child] = _depth[item] + 1
				queue.append(child)

	_max_depth = 1
	for depth in _depth.values():
		_max_depth = maxi(_max_depth, depth)


# Intro: the hub pops in, then every ring of unlocked upgrades pops in one after another,
# with the lines growing out to them. Hint lines come in once their node has popped in.
func _play_intro() -> void:
	intro_outro_animation_playing = true

	_hub.scale = UpgradeButton.HIDDEN_BUTTON_SCALE
	var hub_tween := create_tween()
	hub_tween.tween_property(_hub, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	for item in buttons:
		_shown[item] = item.unlocked
		if item.unlocked:
			buttons[item].play_pop_in(_depth.get(item, 1) * INTRO_ANIMATION_DELAYS + 0.05)

	for entry in _lines:
		var state := _get_line_state(entry)
		var parent: ItemData = entry["parent"]
		var parent_depth: int = 0 if parent == null else _depth.get(parent, 1)
		var delay := parent_depth * INTRO_ANIMATION_DELAYS + (0.4 if state == LineState.HINT else 0.08)
		_set_line_state(entry, state, true, delay)

	await get_tree().create_timer(_max_depth * INTRO_ANIMATION_DELAYS + 0.8).timeout

	for item in buttons:
		if item.unlocked:
			buttons[item].set_interactive(true)
	intro_outro_animation_playing = false
	_sync_unlocks()

func close() -> void:
	if _is_closing:
		return
	_is_closing = true
	intro_outro_animation_playing = true

	if _hovered_item != null:
		description_view.hide_for(_hovered_item)

	for item in buttons:
		var button: UpgradeButton = buttons[item]
		button.set_interactive(false)
		if item.unlocked:
			button.play_close((_max_depth - _depth.get(item, 1)) * OUTRO_ANIMATION_DELAYS)

	for entry in _lines:
		_kill_line_tweens(entry)
		var line = entry["node"]
		if not line.visible:
			continue
		var child_depth: int = _depth.get(entry["child"], 1)
		var tween: Tween = line.create_tween()
		tween.tween_interval((_max_depth - child_depth) * OUTRO_ANIMATION_DELAYS)
		tween.tween_property(line, "end_point", entry["from"], 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(line, "modulate:a", 0.0, 0.25)

	var hub_tween := create_tween()
	hub_tween.tween_interval(_max_depth * OUTRO_ANIMATION_DELAYS + 0.1)
	hub_tween.tween_property(_hub, "scale", UpgradeButton.HIDDEN_BUTTON_SCALE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	# Undo any panning and zooming.
	var pivot_tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	pivot_tween.tween_property(pivot, "position", get_viewport_rect().size * 0.5, 0.4)
	pivot_tween.tween_property(pivot, "scale", Vector2.ONE, 0.4)

	await get_tree().create_timer(_max_depth * OUTRO_ANIMATION_DELAYS + 0.5).timeout
	closed.emit()


# Plays unlock animation and updates lines.
func _sync_unlocks() -> void:
	for item in buttons:
		var unlocked: bool = item.unlocked
		if unlocked and not _shown.get(item, false):
			_play_unlock(item)
		_shown[item] = unlocked
	_update_lines(true)

# The unlock animation. 
func _play_unlock(item: ItemData) -> void:
	var from_position := Vector2.ZERO
	for parent in item.parents:
		if parent.unlocked:
			from_position = centers[parent]
			break
	buttons[item].play_reveal(from_position, 0.12)


func _get_line_state(entry: Dictionary) -> LineState:
	var child: ItemData = entry["child"]
	var parent: ItemData = entry["parent"]
	if child.unlocked:
		return LineState.FULL
	if parent != null and parent.unlocked:
		return LineState.HINT
	return LineState.HIDDEN


func _update_lines(animate: bool) -> void:
	for entry in _lines:
		var new_state := _get_line_state(entry)
		if new_state == entry["state"]:
			continue
		var delay := 0.45 if new_state == LineState.HINT else 0.0
		_set_line_state(entry, new_state, animate, delay)


func _hint_tip(entry: Dictionary) -> Vector2:
	var from: Vector2 = entry["from"]
	var to: Vector2 = entry["to"]
	return from + (to - from).normalized() * minf(LINE_HINT_LENGTH, from.distance_to(to) * 0.6)


func _set_line_state(entry: Dictionary, new_state: LineState, animate: bool, delay: float = 0.0, duration: float = LINE_GROW_TIME) -> void:
	var old_state: LineState = entry["state"]
	entry["state"] = new_state
	_kill_line_tweens(entry)

	var line = entry["node"]
	var from: Vector2 = entry["from"]

	if new_state == LineState.HIDDEN:
		line.visible = false
		return

	var target: Vector2 = entry["to"] if new_state == LineState.FULL else _hint_tip(entry)
	line.edge_color = LINE_COLOR
	line.start_point = from

	if not animate:
		line.end_point = target
		line.modulate.a = 1.0
		line.visible = true
		if new_state == LineState.HINT:
			_pulse_hint(entry)
		return

	if old_state == LineState.HIDDEN:
		line.end_point = from
		line.modulate.a = 1.0
		line.visible = delay <= 0.0

	var tween: Tween = line.create_tween()
	tween.tween_interval(delay)
	tween.tween_callback(line.show)
	tween.tween_property(line, "end_point", target, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(line, "modulate:a", 1.0, duration)
	if new_state == LineState.HINT:
		tween.tween_callback(_pulse_hint.bind(entry))
	entry["tween"] = tween


func _pulse_hint(entry: Dictionary) -> void:
	var line = entry["node"]
	var from: Vector2 = entry["from"]
	var to: Vector2 = entry["to"]
	var tip_in := _hint_tip(entry)
	var tip_out := tip_in + (to - from).normalized() * LINE_HINT_PULSE

	var tween: Tween = line.create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(line, "end_point", tip_out, 0.8)
	tween.parallel().tween_property(line, "modulate:a", 1.0, 0.8)
	tween.tween_property(line, "end_point", tip_in, 0.8)
	tween.parallel().tween_property(line, "modulate:a", 0.4, 0.8)
	entry["pulse"] = tween


func _kill_line_tweens(entry: Dictionary) -> void:
	for key in ["tween", "pulse"]:
		var tween: Tween = entry[key]
		if tween != null and tween.is_valid():
			tween.kill()
		entry[key] = null
