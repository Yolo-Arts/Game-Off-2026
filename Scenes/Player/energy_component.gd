extends Node
class_name PlayerEnergyComponent

var max_energy: float
var current_energy: float
var energy_regen_rate: float
var energy_ram_cost: float
#var can_regenerate: bool

var player: Player

func setup(_player: Player) -> void:
	player = _player
	update_energy()
	current_energy = max_energy
	EventSystem.energy_changed.emit(current_energy, max_energy)
	EventSystem.stat_changed.connect(_on_stat_changed)

#func _physics_process(delta: float) -> void:
	#if can_regenerate:
		#current_energy = clamp(current_energy + energy_regen_rate*delta, 0.0, max_energy)

func update_energy():
	max_energy = player.get_current_stats().max_energy
	energy_ram_cost = player.get_current_stats().energy_ram_cost
	EventSystem.energy_changed.emit(current_energy, max_energy)

#func activate_regen_cooldown(time: int):
	#can_regenerate = false
	#await get_tree().create_timer(time).timeout
	#can_regenerate = true

func reduce_energy(amount: float):
	current_energy = clamp(current_energy - amount, 0.0, max_energy)
	EventSystem.energy_reduced.emit(current_energy)

func increase_energy(amount: float):
	current_energy = clamp(current_energy + amount, 0.0, max_energy)
	EventSystem.energy_increased.emit(current_energy)

func _on_stat_changed(stat: String):
	if stat == "energy":
		update_energy()
