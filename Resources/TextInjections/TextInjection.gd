class_name TextInjection
extends Resource
# A resource that fills one {} placeholder in an item's description.
# It can also replace parts surrounded by [ ]
#
# For example:
# Damage increased by [20%] and luck is increased by {GEARS}. 
# With initial set to 0.2, increment set to 0.2 and percent turned on, it will look like:
# Damage increased by 20% -> 40% and luck is increased by [animated images] GEARS [animated image].

@export var text: String = ""
@export var color: Color = Color(0.0, 0.6, 0.859)

@export var font_size: int = 0

@export var icon: Texture2D
@export var icon_size: Vector2i = Vector2i(20, 36)
@export var wave: bool = true


func get_string(_level: int) -> String:
	var result := tr(text)
	if font_size > 0:
		result = "[font_size=%d]%s[/font_size]" % [font_size, result]
	if icon != null and not icon.resource_path.is_empty():
		var img := "[img=%dx%d]%s[/img]" % [icon_size.x, icon_size.y, icon.resource_path]
		result = "%s %s %s" % [img, result, img]
	if wave:
		result = "[wave amp=15.0 freq=2.5]%s[/wave]" % result
	return "[color=%s]%s[/color]" % [color.to_html(false), result]
