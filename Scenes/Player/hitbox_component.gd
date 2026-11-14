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
	if !enabled:
		return
	var stats: PlayerStats = player.get_current_stats()
	var damage_source := DamageSource.new(stats.get_computed_damage(), stats.knockback, DamageSource.DamageSourceType.PLAYER, player.shift_color, player)
	if not player.can_ram():
		damage_source.damage = 0
	if body.has_method(&"take_damage"):
		body.take_damage(damage_source)
