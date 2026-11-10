extends Control
class_name UpgradeDescriptionView

# skill_tree.gd calls show_for() , hide_for() , play_buy() , play_cannot_buy().

const COLOR_DIM := Color(0.5, 0.5, 0.5)
const COLOR_MAXED := Color(1.0, 0.8, 0.2)
const COLOR_BOUGHT := Color(0.324, 0.83, 0.935)
const COLOR_DENIED := Color(1.0, 0.3, 0.3)

@export var packed_pricebar: PackedScene

var _item: ItemData
var _size_tween: Tween
var _feedback_tween: Tween
var _rectangle_anchor_ratio: Vector2:
	set(value):
		_rectangle_anchor_ratio = value
		background_rectangle_shape.anchor_ratio = _rectangle_anchor_ratio
		clipping_rectangle_shape.anchor_ratio = _rectangle_anchor_ratio
		fully_upgraded_rectangle_shape.anchor_ratio = _rectangle_anchor_ratio
		foreground_rectangle_shape.anchor_ratio = _rectangle_anchor_ratio

@onready var pivot_control: Control = %PivotControl
@onready var background_rectangle_shape: RectangleShape = %BackgroundRectangleShape
@onready var clipping_rectangle_shape: RectangleShape = %ClippingRectangleShape
@onready var margin_container: MarginContainer = %MarginContainer
@onready var fully_upgraded_rectangle_shape: RectangleShape = %FullyUpgradedRectangleShape
@onready var foreground_rectangle_shape: RectangleShape = %ForegroundRectangleShape
@onready var upgrade_name_label: Label = %UpgradeNameLabel
@onready var upgrade_description_label: RichTextLabel = %UpgradeDescriptionLabel

@onready var pricebar_container: VBoxContainer = %PricebarContainer

@onready var level_label_pivot: Control = %LevelLabelPivot
@onready var level_label: Label = %LevelLabel


func _ready() -> void:
	upgrade_description_label.bbcode_enabled = true
	upgrade_description_label.fit_content = true
	upgrade_description_label.scroll_active = false

	for currency_data in Currencies.get_all():
		var new_pricebar := packed_pricebar.instantiate() as Pricebar
		new_pricebar.inject_currency_data(currency_data)
		pricebar_container.add_child(new_pricebar)

	z_index = 10

	fully_upgraded_rectangle_shape.edge_color = COLOR_MAXED
	fully_upgraded_rectangle_shape.hide()

	_ignore_mouse(self)

	Currencies.changed.connect(_refresh_content)
	SkillTreeUpgrades.changed.connect(_on_upgrades_changed)

	_hide_upgrade()


func show_for(item: ItemData, anchor_global_position: Vector2) -> void:
	_item = item
	global_position = anchor_global_position
	_refresh_content()
	show()
	_layout_panel()


func hide_for(item: ItemData) -> void:
	if item == _item:
		_hide_upgrade()


func play_buy() -> void:
	_reset_feedback()
	_feedback_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	_feedback_tween.tween_property(self, "scale", Vector2.ONE * 1.05, 0.1)
	_feedback_tween.parallel().tween_property(foreground_rectangle_shape, "edge_color", COLOR_BOUGHT, 0.1)
	_feedback_tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	_feedback_tween.parallel().tween_property(foreground_rectangle_shape, "edge_color", Color.WHITE, 0.1)


func play_cannot_buy() -> void:
	_reset_feedback()
	_feedback_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	_feedback_tween.tween_property(self, "rotation_degrees", -1.5, 0.05)
	_feedback_tween.parallel().tween_property(foreground_rectangle_shape, "edge_color", COLOR_DENIED, 0.05)
	_feedback_tween.tween_property(self, "rotation_degrees", 1.5, 0.1)
	_feedback_tween.tween_property(self, "rotation_degrees", 0.0, 0.05)
	_feedback_tween.parallel().tween_property(foreground_rectangle_shape, "edge_color", Color.WHITE, 0.1)


func _on_upgrades_changed() -> void:
	if _item == null:
		return
	_refresh_content()
	_layout_panel() 

# Populates the tooltip with ItemData details.'
func _refresh_content() -> void:
	if _item == null:
		return

	upgrade_name_label.text = _item.display_name

	var description := _item.description
	var stats := _item.get_stats_display_string().strip_edges()
	if not stats.is_empty():
		description += "\n\n" + stats
	upgrade_description_label.text = "[center]" + description

	var maxed := _item.is_maxed()
	var dimmed := not maxed and not SkillTreeUpgrades.can_buy(_item)
	var tint := COLOR_DIM if dimmed else Color.WHITE
	upgrade_name_label.modulate = tint
	upgrade_description_label.modulate = tint
	foreground_rectangle_shape.modulate = tint
	level_label.modulate = tint

	pricebar_container.visible = not maxed
	fully_upgraded_rectangle_shape.visible = maxed
	level_label.visible = maxed or _item.max_level > 1

	if maxed and _item.max_level <= 1:
		level_label.text = "UNLOCKED"
	else:
		level_label.text = "Lv. %d / %d" % [_item.level, _item.max_level]

	if not maxed:
		for pricebar in pricebar_container.get_children():
			pricebar.inject_upgrade_data(_item)

# Spawns in the tooltip.
func _layout_panel() -> void:
	var current_item := _item
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	if _item == null or _item != current_item:
		return
	
	# Flips tooltip position depending on button node location on screen.
	var node_screen_origin := get_global_transform_with_canvas().origin
	var node_scale := get_global_transform_with_canvas().get_scale()
	var viewport_height := get_viewport_rect().size.y
	var bottom_screen_y := node_screen_origin.y + margin_container.size.y * absf(node_scale.y)
	
	var show_above := bottom_screen_y > (viewport_height - 10.0)

	if show_above:
		margin_container.add_theme_constant_override("margin_top", 30)
		margin_container.add_theme_constant_override("margin_bottom", 55)
		margin_container.position.y = -margin_container.size.y
		_rectangle_anchor_ratio = Vector2(0.5, 1.0)
		fully_upgraded_rectangle_shape.position.y = -6.0
	else:
		margin_container.add_theme_constant_override("margin_top", 55)
		margin_container.add_theme_constant_override("margin_bottom", 30)
		margin_container.position.y = 0.0
		_rectangle_anchor_ratio = Vector2(0.5, 0.0)
		fully_upgraded_rectangle_shape.position.y = 6.0
		
	if _size_tween != null:
		_size_tween.kill()
		
	var target_label_y := margin_container.position.y
	
	_size_tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_size_tween.tween_property(level_label_pivot, "position:x", margin_container.size.x - 20.0, 0.2)
	_size_tween.tween_property(level_label_pivot, "position:y", target_label_y, 0.2)
	_size_tween.tween_property(background_rectangle_shape, "size", margin_container.size, 0.2)
	_size_tween.tween_property(clipping_rectangle_shape, "size", margin_container.size, 0.2)
	_size_tween.tween_property(foreground_rectangle_shape, "size", margin_container.size, 0.2)
	_size_tween.tween_property(fully_upgraded_rectangle_shape, "size", margin_container.size - 12 * Vector2.ONE, 0.2)
	_size_tween.tween_property(level_label, "scale", Vector2.ONE, 0.2).set_delay(0.15)


func _hide_upgrade() -> void:
	_item = null
	if _size_tween != null:
		_size_tween.kill()
	_reset_feedback()

	level_label_pivot.position = Vector2.ONE
	background_rectangle_shape.size = Vector2.ONE
	clipping_rectangle_shape.size = Vector2.ONE
	foreground_rectangle_shape.size = Vector2.ONE
	fully_upgraded_rectangle_shape.size = Vector2.ONE
	level_label.scale = Vector2.ZERO
	hide()


func _reset_feedback() -> void:
	if _feedback_tween != null:
		_feedback_tween.kill()
	scale = Vector2.ONE
	rotation_degrees = 0.0
	foreground_rectangle_shape.edge_color = Color.WHITE


func _ignore_mouse(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_mouse(child)
