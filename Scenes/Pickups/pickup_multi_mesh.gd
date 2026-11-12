extends MultiMeshInstance2D

const MONITOR_ID := "game/pickup_count"

const PAYOUT_INTERVAL := 0.05

@export var world_rect: Rect2 = Rect2(-25000, -25000, 50000, 50000)
@export var max_pickups: int = 10000
@export var mesh_size: Vector2 = Vector2(4, 4)

@export var pickup_sfx_config: SFXConfig.Keys

var _quad_tree: QuadTree

# Dictionary[instance_id, PickupReference]
var _pickup_instance_dictionary: Dictionary = {} 
# Dictionary[spawn_position, PickupReference]
var _position_dictionary: Dictionary = {} 
# Dictionary[Enums.CurrencyType, int]
var _pending_amounts: Dictionary = {} 
var _sfx_player: AudioStreamPlayer
var _last_sfx_msec: int = 0
var _payout_cooldown: float = 0.0


func _ready() -> void:
	_quad_tree = QuadTree.new(world_rect)
	_setup_multimesh()

	Pickups.spawn_requested.connect(_add_pickup_instance)
	Pickups.despawn_all_requested.connect(_on_despawn_all_pickups)
	
	if Performance.has_custom_monitor(MONITOR_ID):
		Performance.remove_custom_monitor(MONITOR_ID)
	Performance.add_custom_monitor(MONITOR_ID, func() -> int: return _pickup_instance_dictionary.size())

	hide()


func _exit_tree() -> void:
	if Performance.has_custom_monitor(MONITOR_ID):
		Performance.remove_custom_monitor(MONITOR_ID)
	if Pickups.spawn_requested.is_connected(_add_pickup_instance):
		Pickups.spawn_requested.disconnect(_add_pickup_instance)
	if Pickups.despawn_all_requested.is_connected(_on_despawn_all_pickups):
		Pickups.despawn_all_requested.disconnect(_on_despawn_all_pickups)

func _setup_multimesh() -> void:
	var new_multimesh := MultiMesh.new()
	new_multimesh.transform_format = MultiMesh.TRANSFORM_2D
	new_multimesh.use_colors = true
	new_multimesh.use_custom_data = true

	var quad := QuadMesh.new()
	quad.size = mesh_size
	new_multimesh.mesh = quad

	new_multimesh.instance_count = max_pickups
	new_multimesh.visible_instance_count = 0
	multimesh = new_multimesh


func _process(delta: float) -> void:
	_payout_cooldown -= delta
	if _payout_cooldown <= 0.0:
		_flush_pending_currency()

	if get_tree().get_frame() % 5 > 0: return

	var collector := Pickups.get_collector()
	if collector == null: return

	collect_in_radius(collector.global_position, Pickups.pickup_radius)



func collect_in_radius(center: Vector2, radius: float) -> void:
	for pickup_position in _quad_tree.find_all_in_radius(center, radius):
		var pickup_reference: PickupReference = _position_dictionary.get(pickup_position)
		if pickup_reference == null: continue
		if not pickup_reference.pickable: continue
		if pickup_reference.collected: continue

		_start_collecting(pickup_reference)


func _add_pickup_instance(currency_data: CurrencyData, spawn_position: Vector2) -> void:
	if not is_inside_tree():
		return
	
	if _pickup_instance_dictionary.size() >= max_pickups:
		_queue_currency(currency_data.type, Pickups.value_per_pickup)
		return
	
	spawn_position = spawn_position.clamp(world_rect.position + Vector2.ONE, world_rect.end - Vector2.ONE)
	
	while _position_dictionary.has(spawn_position):
		spawn_position += Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))

	var pickup_reference := PickupReference.new()
	pickup_reference.updated_transform.connect(_write_transform.bind(pickup_reference))
	pickup_reference.updated_color.connect(_write_color.bind(pickup_reference))

	pickup_reference.instance_id = _pickup_instance_dictionary.size()
	pickup_reference.currency_data = currency_data
	pickup_reference.spawn_position = spawn_position
	pickup_reference.position = spawn_position
	
	pickup_reference.custom_data = Color(randf_range(0.9, 1.1), randi_range(0, 3), currency_data.sprite_index, 0)

	var tint := currency_data.color
	tint.v *= randf_range(0.8, 1.2)
	pickup_reference.color = tint

	_pickup_instance_dictionary[pickup_reference.instance_id] = pickup_reference
	_position_dictionary[spawn_position] = pickup_reference
	_quad_tree.insert(spawn_position)

	multimesh.visible_instance_count = _pickup_instance_dictionary.size()
	visible = true

	_spawn_pickup(pickup_reference)
	_write_custom_data(pickup_reference)
	_write_transform(pickup_reference)

	get_tree().create_timer(Pickups.despawn_time).timeout.connect(_despawn_pickup.bind(pickup_reference, true))


func _remove_pickup_instance(pickup_reference: PickupReference) -> void:
	if pickup_reference.is_removed: return
	pickup_reference.is_removed = true

	_untrack(pickup_reference)

	var last_instance_id := _pickup_instance_dictionary.size() - 1
	var freed_instance_id := pickup_reference.instance_id

	if freed_instance_id != last_instance_id:
		var moved: PickupReference = _pickup_instance_dictionary[last_instance_id]
		moved.instance_id = freed_instance_id
		_pickup_instance_dictionary[freed_instance_id] = moved

		_write_custom_data(moved)
		_write_transform(moved)
		_write_color(moved)

	_pickup_instance_dictionary.erase(last_instance_id)
	multimesh.visible_instance_count = _pickup_instance_dictionary.size()
	visible = not _pickup_instance_dictionary.is_empty()


func _untrack(pickup_reference: PickupReference) -> void:
	if _position_dictionary.erase(pickup_reference.spawn_position):
		_quad_tree.remove(pickup_reference.spawn_position)


func _write_custom_data(pickup_reference: PickupReference) -> void:
	if pickup_reference.is_removed: return
	multimesh.set_instance_custom_data(pickup_reference.instance_id, pickup_reference.custom_data)


func _write_transform(pickup_reference: PickupReference) -> void:
	if pickup_reference.is_removed: return
	var new_transform := Transform2D(0.0, pickup_reference.scale, 0.0, pickup_reference.position)
	multimesh.set_instance_transform_2d(pickup_reference.instance_id, new_transform)


func _write_color(pickup_reference: PickupReference) -> void:
	if pickup_reference.is_removed: return
	multimesh.set_instance_color(pickup_reference.instance_id, pickup_reference.color)


func _spawn_pickup(pickup_reference: PickupReference) -> void:
	pickup_reference.color.a = 0.0
	pickup_reference.scale = 0.7 * Vector2.ONE

	var tween_time := randf_range(0.1, 0.2)

	var tween := create_tween().set_parallel()
	tween.tween_property(pickup_reference, "scale", randf_range(3.5, 4.5) * Vector2.ONE, tween_time).set_delay(randf_range(0.0, 0.1)).set_trans(Tween.TRANS_BACK)
	tween.tween_property(pickup_reference, "color:a", 1.0, tween_time).set_delay(randf_range(0.0, 0.2))

	await tween.finished
	pickup_reference.pickable = true


func _start_collecting(pickup_reference: PickupReference) -> void:
	if pickup_reference.collected or pickup_reference.is_removed: return
	pickup_reference.collected = true
	_untrack(pickup_reference)
	
	var from_position := pickup_reference.position
	var tween_time := randf_range(0.4, 0.6)
	
	
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_method(func(weight: float) -> void:
		pickup_reference.position = from_position.lerp(_get_collect_target(from_position), weight)
	, 0.0, 1.0, tween_time).set_delay(randf_range(0.0, 0.1))
	tween.parallel().tween_property(pickup_reference, "scale", randf_range(4.4, 5.4) * Vector2.ONE, tween_time)
	tween.parallel().tween_property(pickup_reference, "color", Color.WHITE, tween_time / 10.0).set_delay(tween_time * 9.0 / 10.0)

	await tween.finished
	_collect(pickup_reference)


func _get_collect_target(fallback: Vector2) -> Vector2:
	var collector := Pickups.get_collector()
	if collector == null: return fallback
	return collector.global_position


func _collect(pickup_reference: PickupReference) -> void:
	if pickup_reference.is_removed: return

	_queue_currency(pickup_reference.currency_data.type, Pickups.value_per_pickup)
	Pickups.collected.emit(pickup_reference)
	_remove_pickup_instance(pickup_reference)
	_play_sfx()

func _queue_currency(type: Enums.CurrencyType, amount: int) -> void:
	_pending_amounts[type] = _pending_amounts.get(type, 0) + amount


func _flush_pending_currency() -> void:
	if _pending_amounts.is_empty(): return

	_payout_cooldown = PAYOUT_INTERVAL
	for type in _pending_amounts:
		Currencies.add(type, _pending_amounts[type])
	_pending_amounts.clear()


func _play_sfx() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_sfx_msec < 60: 
		return
	
	_last_sfx_msec = now
	EventSystem.SFX_play_sfx.emit(pickup_sfx_config)


func _on_despawn_all_pickups() -> void:
	for pickup_reference in _pickup_instance_dictionary.values():
		if pickup_reference.collected: continue
		get_tree().create_timer(randf_range(0.0, 1.0)).timeout.connect(_despawn_pickup.bind(pickup_reference))


func _despawn_pickup(pickup_reference: PickupReference, has_expired: bool = false) -> void:
	if pickup_reference.collected or pickup_reference.is_removed: return

	if not has_expired and Pickups.collect_chance > randi_range(0, 100):
		_start_collecting(pickup_reference)
		return

	_untrack(pickup_reference)

	var tween := create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(pickup_reference, "color:a", 0.0, 0.3)

	await tween.finished
	_remove_pickup_instance(pickup_reference)
