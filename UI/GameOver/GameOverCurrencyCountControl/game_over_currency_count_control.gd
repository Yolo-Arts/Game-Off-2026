extends VBoxContainer

@onready var currency_icon = %CurrencyIcon
@onready var currency_label = %CurrencyLabel

var _current_value: int = -1
var _data: CurrencyData

func _ready() -> void:
	initial_setup()

func inject_data(data: CurrencyData) -> void :
	_data = data

func initial_setup() -> void:
	await get_tree().process_frame
	_current_value = _data.amount
	
	if _data.amount < 1:
		visible = false
	currency_label.text = add_spaces_to_number("%d" % _current_value)
	currency_icon.modulate = _data.color

func add_spaces_to_number(number: String) -> String:
	var text_string: String = number
	var i = 0
	var space_index = 3 + 4 * i
	while text_string.length() > space_index:
		text_string = text_string.insert(text_string.length() - space_index, " ")
		i += 1
		space_index = 3 + 4 * i
	return text_string
