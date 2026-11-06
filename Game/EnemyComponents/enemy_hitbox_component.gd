class_name EnemyHitbox extends Area2D

@export var enabled: bool = false
@export var enemy: Node2D
@export var damage: float
#@export var knockback: float

func _init() -> void:
	collision_mask = 2
	add_to_group("enemy_hitbox")
	EventSystem.player_vincible.connect(apply_hit)
	area_entered.connect(apply_hit.unbind(1))
	
func setup(_enemy: Node2D, _damage: float, _knockback: float, _enabled: bool = true) -> void:
	enabled = _enabled
	enemy = _enemy
	damage = _damage
	
func apply_hit(effective_damage := damage) -> void:
	if not enabled: return
	var areas: Array[Area2D] = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("player_hurtbox"):
			EventSystem.player_hit.emit(effective_damage, enemy)
			return
	
