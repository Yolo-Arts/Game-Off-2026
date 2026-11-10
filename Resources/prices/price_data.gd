class_name PriceData
extends Resource

@export var currency: Enums.CurrencyType
@export var initial_price: int = 0
@export var price_multiplier: float = 1.6

func get_cost(level: int) -> int:
	return int(initial_price * pow(price_multiplier, level))
