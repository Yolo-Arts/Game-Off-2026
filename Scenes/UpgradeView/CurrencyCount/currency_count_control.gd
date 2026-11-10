extends HBoxContainer
class_name CurrencyCountControl

# TODO: Yolo: Honestly not sure what happens when you unlock a new currency so that will be fun to find out. In theory it should work.
# TODO: Currencies may stay hidden due to uprade_view.gd but it could also work. :thinking:

@onready var rectangle_shape = %RectangleShape
@onready var animated_sprite_2d = %AnimatedSprite2D
@onready var main_anchor = %MainAnchor
@onready var label = %Label

var _data: CurrencyData
var _current_value: int = -1

func inject_data(data: CurrencyData) -> void :
	_data = data

func _ready() -> void :
	await get_tree().process_frame
	
	minimum_size_changed.connect( func(): pivot_offset = size / 2.0)
	
	_data.currency_count_node = main_anchor
	_data.amount_changed.connect(_update_count)
	#_data.update_amount.connect(_update_count)
	_data.insufficient_amount_triggered.connect(_on_insufficient_amount_triggered)
	
	initial_setup()
	

func initial_setup() -> void:
	_current_value = _data.amount
	label.text = add_spaces_to_number("%d" % _current_value)
	rectangle_shape.size.x = 170 + (label.size.x - 25)
	rectangle_shape.edge_color = _data.color
	#rectangle_shape.fill_color = Color(_data.color, 40)
	rectangle_shape.fill_color = Color(0.0, 0.0, 0.0, 0.133)
	animated_sprite_2d.modulate = _data.color
	
	if animated_sprite_2d.sprite_frames and animated_sprite_2d.sprite_frames.has_animation(_data.name):
			animated_sprite_2d.animation = _data.name
			animated_sprite_2d.play()

func _update_count() -> void :
	if !_data.is_visible: return

	show()

	_current_value = _data.amount
	label.text = add_spaces_to_number("%d" % _current_value)
	
	rectangle_shape.size.x = 140 + (label.size.x - 41)

	TweenManager.scale_up_and_down(animated_sprite_2d, 2.5, 2.0, 0.1, 0.1)
	TweenManager.scale_up_and_down(self, 1.25, 1.0, 0.1, 0.1)
	TweenManager.scale_up_and_down(label, 1.25, 1.0, 0.1, 0.1)
	TweenManager.flash(label, Color.RED, Color.WHITE, 0.25, 0.025)

func _on_insufficient_amount_triggered() -> void :
	if !is_visible_in_tree(): return

	TweenManager.flash(label, Color.RED, Color.WHITE, 0.2, 0.1)
	TweenManager.shake(label, 3.0, 0.1)

func add_spaces_to_number(number: String) -> String:
	var text_string: String = number
	var i = 0
	var space_index = 3 + 4 * i
	while text_string.length() > space_index:
		text_string = text_string.insert(text_string.length() - space_index, " ")
		i += 1
		space_index = 3 + 4 * i
	return text_string
