class_name Pricebar
extends HBoxContainer

const COLOR_DIM := Color(0.5, 0.5, 0.5)

@onready var pricebar_rectangle_shape: RectangleShape = %RectangleShape
@onready var pricebar_rectangle_shape_2: RectangleShape = %RectangleShape2
@onready var currency_price_label: Label = %CurrencyPriceLabel
@onready var start_animated_sprite_2d: AnimatedSprite2D = %StartCurrencySymbol
@onready var end_animated_sprite_2d: AnimatedSprite2D = %StartCurrencySymbol2

var _currency_data: CurrencyData
var _upgrade_data: ItemData
var _sprite_base_scale: Vector2
var _pulse_tween: Tween
var _shake_tween: Tween


## Call BEFORE add_child().
func inject_currency_data(currency_data: CurrencyData) -> void:
	_currency_data = currency_data


func inject_upgrade_data(upgrade_data: ItemData) -> void:
	_upgrade_data = upgrade_data
	update_amount()


func _ready() -> void:
	_currency_data.amount_changed.connect(_pulse_sprites)
	_currency_data.amount_changed.connect(update_amount)
	_currency_data.insufficient_amount_triggered.connect(_on_insufficient_amount_triggered)

	var color = _currency_data.color
	pricebar_rectangle_shape.edge_color = color
	pricebar_rectangle_shape.fill_color = color
	pricebar_rectangle_shape.fill_color.a = 50.0 / 255.0
	pricebar_rectangle_shape_2.edge_color = color

	_sprite_base_scale = start_animated_sprite_2d.scale
	for sprite in [start_animated_sprite_2d, end_animated_sprite_2d]:
		sprite.modulate = color
	
	hide()


func update_amount() -> void:
	if _upgrade_data == null or _currency_data == null:
		return

	var price = _upgrade_data.get_price(_currency_data.type)
	if price <= 0:
		hide()
		return

	var available = _currency_data.amount
	currency_price_label.text = add_spaces_to_number(str(available)) + " / " + add_spaces_to_number(str(price))
	pricebar_rectangle_shape.size.x = size.x * clampi(available, 0, price) / price
	modulate = COLOR_DIM if available < price else Color.WHITE
	show()


func add_spaces_to_number(number: String) -> String:
	var text_string: String = number
	var i = 0
	var space_index = 3 + 4 * i
	while text_string.length() > space_index:
		text_string = text_string.insert(text_string.length() - space_index, " ")
		i += 1
		space_index = 3 + 4 * i
	return text_string


func _on_insufficient_amount_triggered() -> void:
	if _shake_tween:
		_shake_tween.kill()
	currency_price_label.pivot_offset = currency_price_label.size * 0.5
	currency_price_label.modulate = Color.RED
	currency_price_label.rotation_degrees = 0.0
	_shake_tween = create_tween()
	_shake_tween.tween_property(currency_price_label, "rotation_degrees", 3.0, 0.03)
	_shake_tween.tween_property(currency_price_label, "rotation_degrees", -3.0, 0.06)
	_shake_tween.tween_property(currency_price_label, "rotation_degrees", 0.0, 0.03)
	_shake_tween.tween_property(currency_price_label, "modulate", Color.WHITE, 0.2)


func _pulse_sprites() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
	_pulse_tween = create_tween().set_parallel()
	for sprite in [start_animated_sprite_2d, end_animated_sprite_2d]:
		sprite.scale = _sprite_base_scale
		_pulse_tween.tween_property(sprite, "scale", _sprite_base_scale * 1.25, 0.1)
		_pulse_tween.tween_property(sprite, "scale", _sprite_base_scale, 0.1).set_delay(0.1)
