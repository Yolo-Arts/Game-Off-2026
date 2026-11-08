class_name PlayerHitbox extends Area2D

var player: Player

var enabled: bool = false

func _ready() -> void:
	collision_mask = 4
	add_to_group("player_hitbox")
	body_entered.connect(_on_body_entered)

func setup(_player: Player, enable: bool = true) -> void:
	player = _player
	enabled = enable
	
func _on_body_entered(body: Node2D) -> void:
	if !enabled or not player.can_ram():
		return
	var enemy: Enemy = body as Enemy
	
	if enemy:
		enemy.health_component.take_damage(enemy.health_component.current_health)
	
