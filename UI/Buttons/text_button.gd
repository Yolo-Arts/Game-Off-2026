@tool
class_name TextButton
extends MyButton

@onready var label: RichTextLabel = %RichTextLabel
@export var font_size: int = 28
@export var btn_text: String = "" :
	set(val):
		btn_text = val
		if not is_node_ready(): await ready
		label.text = "[center]%s[/center]" % btn_text
		label.propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)
		update_label_size()


func _ready() -> void:
	super._ready()
	resized.connect(_on_resized)
	label.resized.connect(update_label_size)
	label.add_theme_font_size_override("normal_font_size", font_size)

# Workaround for 0.5 pixel issue when centering
func update_label_size() -> void:
	if int(label.size.x) % 2 == 0:
		if label.offset_right == 0: label.offset_right = 1
		else: label.offset_right = 0

func _on_resized() -> void:
	if int(size.y) % 2 == 1:
		label.offset_top = 1
	else:
		label.offset_top = 0
