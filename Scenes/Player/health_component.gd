extends Node
class_name PlayerHealthComponent

var max_health: float
var current_health: float
var invincibility_sources: Dictionary[StringName, bool] = {}
var player: Player

func setup(_player: Player) -> void:
	player = _player
	update_health()
	current_health = max_health
	EventSystem.health_changed.emit(current_health, max_health)
	EventSystem.stat_changed.connect(_on_stat_changed)

## Updates health when the health stat changes
func _on_stat_changed(stat: String) -> void:
	if stat == "max_health":
		update_health()

## Updates the health from [PlayerStats]
func update_health() -> void:

	var current_stats: PlayerStats = player.get_current_stats()
	max_health = current_stats.max_health
	EventSystem.health_changed.emit(current_health, max_health)

func is_invincible() -> bool:
	return invincibility_sources.size() > 0
 
func add_invincibility(source: StringName) -> void:
	invincibility_sources[source] = true
	if invincibility_sources.size() == 1:
		EventSystem.player_invincible.emit()

func remove_invincibility(source: StringName) -> void:
	invincibility_sources.erase(source)
	if not is_invincible():
		EventSystem.player_vincible.emit()

func take_damage(source: DamageSource) -> bool:
	if current_health <= 0:
		return false
	if is_invincible():
		if source.damage_type != DamageSource.DamageSourceType.AUTO_DAMAGE:
			return false
	
	if source.shift_color == player.shift_color and \
	player.can_ram():
		return false
		
	current_health = clamp(current_health - source.damage, 0.0, max_health)
	EventSystem.health_reduced.emit(current_health)
	if current_health <= 0:
		EventSystem.player_died.emit()
	elif source.damage_type != DamageSource.DamageSourceType.AUTO_DAMAGE:
		_start_iframes()
	return true

func heal(amount: float) -> void:
	current_health = clamp(current_health + amount, 0.0, max_health)
	EventSystem.player_healed.emit(amount)
	EventSystem.health_increased.emit(current_health)


func _start_iframes() -> void:
	add_invincibility(&"iframes")
	await get_tree().create_timer(player.get_current_stats().invincibility_duration_seconds).timeout
	remove_invincibility(&"iframes")
