extends Node

signal spawn_requested(currency_data: CurrencyData, spawn_position: Vector2)
signal despawn_all_requested
signal collected(pickup_reference: PickupReference)

const COLLECTOR_GROUP := &"pickup_collector"
const GOLDEN_ANGLE := 2.399963

var despawn_time: float = 45.0 
var pickup_radius: float = 150.0 
var collect_chance: int = 0 
var value_per_pickup: int = 1 

var _collector: Node2D


func get_collector() -> Node2D:
	if not is_instance_valid(_collector):
		_collector = get_tree().get_first_node_in_group(COLLECTOR_GROUP) as Node2D
	return _collector


func spawn(type: Enums.CurrencyType, spawn_position: Vector2, amount: int = 1) -> void:
	var currency_data := Currencies.get_currency(type)
	for i in amount:
		var offset := Vector2.RIGHT.rotated(i * GOLDEN_ANGLE) * 6.0 * sqrt(i)
		spawn_requested.emit(currency_data, spawn_position + offset)


func despawn_all() -> void:
	despawn_all_requested.emit()
