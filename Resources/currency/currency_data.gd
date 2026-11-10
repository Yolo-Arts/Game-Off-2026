class_name CurrencyData
extends Resource

signal amount_changed
signal insufficient_amount_triggered

@export var name: String
@export var type: Enums.CurrencyType
@export var color: Color = Color.WHITE

var amount: int = 0


func add(value: int) -> void:
	if value == 0:
		return
	amount += value
	amount_changed.emit()


func can_afford(cost: int) -> bool:
	return amount >= cost


func spend(cost: int) -> bool:
	if cost <= 0:
		push_error("Cant spend a negative number...")
		return true
	if not can_afford(cost):
		# A UI effect signal.
		insufficient_amount_triggered.emit()
		return false
	
	amount -= cost
	amount_changed.emit()
	return true
