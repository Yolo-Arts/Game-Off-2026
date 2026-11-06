class_name UpgradeButton
extends Node2D

const SIZE := Vector2(48, 48)
const COLOR_MAXED := Color(1.0, 0.8, 0.2)
const COLOR_DIM := Color(0.5, 0.5, 0.5)

var item: ItemData   

@onready var shape = %Shape
@onready var texture_button = %TextureButton


func _ready() -> void:
	shape.sides = 4
	shape.radius = 34.0

	texture_button.flat = true
	texture_button.focus_mode = Control.FOCUS_NONE
	texture_button.size = SIZE
	texture_button.position = -SIZE * 0.5
	texture_button.icon = item.icon
	texture_button.expand_icon = true
	texture_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texture_button.add_theme_constant_override("icon_max_width", 28)
	texture_button.pressed.connect(func(): SkillTreeUpgrades.buy(item))


func refresh() -> void:
	visible = item.unlocked

	var color := Color.WHITE
	if item.is_maxed():
		color = COLOR_MAXED
	elif not SkillTreeUpgrades.can_buy(item):
		color = COLOR_DIM

	shape.edge_color = color
	texture_button.modulate.a = 0.5 if color == COLOR_DIM else 1.0
	texture_button.tooltip_text = _tooltip()
	queue_redraw()


func _tooltip() -> String:
	var text := "%s (%d/%d)\n%s\n%s" % [
		item.display_name, item.level, item.max_level,
		item.description, item.get_stats_display_string()]
	if not item.is_maxed():
		text += "Cost: %d" % item.cost()
	return text


func _draw() -> void:
	if item == null or item.max_level <= 1:
		return
	for i in item.max_level:
		var x := (i - (item.max_level - 1) / 2.0) * 9.0
		draw_circle(Vector2(x, 44), 3.0, Color(0.4, 1.0, 0.4), i < item.level)
