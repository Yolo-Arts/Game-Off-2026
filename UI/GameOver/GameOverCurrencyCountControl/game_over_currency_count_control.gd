extends VBoxContainer

@onready var currency_icon = %CurrencyIcon
@onready var currency_label = %CurrencyLabel



func _ready() -> void:
	initial_setup()

func initial_setup() -> void:
	pass

func add_spaces_to_number(number: String) -> String:
	var text_string: String = number
	var i = 0
	var space_index = 3 + 4 * i
	while text_string.length() > space_index:
		text_string = text_string.insert(text_string.length() - space_index, " ")
		i += 1
		space_index = 3 + 4 * i
	return text_string
