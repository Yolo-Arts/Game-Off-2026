class_name PickupReference
extends RefCounted

signal updated_transform
signal updated_color

var instance_id: int
var currency_data: CurrencyData
var custom_data: Color

var spawn_position: Vector2

var position: Vector2:
	set(value):
		position = value
		_queue_transform_update()

var scale: Vector2 = Vector2.ONE:
	set(value):
		scale = value
		_queue_transform_update()

var color: Color:
	set(value):
		color = value
		updated_color.emit()

var pickable: bool = false
var collected: bool = false
var is_removed: bool = false

var _transform_update_queued: bool = false


func _queue_transform_update() -> void:
	if _transform_update_queued:
		return

	_transform_update_queued = true
	await Pickups.get_tree().process_frame
	_transform_update_queued = false

	if not is_removed:
		updated_transform.emit()
