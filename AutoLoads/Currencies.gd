extends Node

signal changed

# Dictionary[Enums.CurrencyType, CurrencyData]
var _by_type: Dictionary = {}

func _init() -> void:
	_register(Enums.CurrencyType.GEAR, "Gears", Color(0.78, 0.8, 0.85), 0)
	_register(Enums.CurrencyType.STAR, "Stars", Color(1.0, 0.85, 0.3), 1)

func _ready() -> void:
	SaveManager.data_saved.connect(_on_data_saved)
	SaveManager.data_loaded.connect(_on_data_loaded)

func _register(type: Enums.CurrencyType, display_name: String, color: Color, sprite_index: int) -> void:
	var currency := CurrencyData.new()
	currency.type = type
	currency.name = display_name
	currency.color = color
	currency.sprite_index = sprite_index
	currency.amount_changed.connect(changed.emit)
	_by_type[type] = currency

func _on_data_saved() -> void:
	SaveManager.data.currency_amounts.clear()
	for type: Enums.CurrencyType in _by_type:
		SaveManager.data.currency_amounts[type] = _by_type[type].amount

func _on_data_loaded() -> void:
	for type: Enums.CurrencyType in _by_type:
		var saved_amount: int = SaveManager.data.currency_amounts.get(type, 0)
		_by_type[type].amount = saved_amount
	changed.emit()

func get_currency(type: Enums.CurrencyType) -> CurrencyData:
	return _by_type[type]

func get_all() -> Array[CurrencyData]:
	var result: Array[CurrencyData] = []
	for currency in _by_type.values():
		result.append(currency)
	return result

func get_amount(type: Enums.CurrencyType) -> int:
	return get_currency(type).amount

func add(type: Enums.CurrencyType, value: int) -> void:
	get_currency(type).add(value)

## Dictionary[Enums.CurrencyType, int]
func can_afford(prices: Dictionary) -> bool:
	for type in prices:
		if not get_currency(type).can_afford(prices[type]):
			return false
	return true

func try_spend(prices: Dictionary) -> bool:
	var can_spend := true
	
	for type in prices:
		var currency := get_currency(type)
		if not currency.can_afford(prices[type]):
			currency.insufficient_amount_triggered.emit()
			can_spend = false
	
	if not can_spend:
		return false
	
	for type in prices:
		get_currency(type).spend(prices[type])
	
	return true
