extends Area2D
class_name ArenaBorder

@export var knockback_strength : float = 720.0
@export var boundary_damage : float = 5.0

var player : Player
var _knockback_cooldown : Timer

func _ready() -> void:
	_knockback_cooldown = Timer.new()
	_knockback_cooldown.one_shot = true
	_knockback_cooldown.autostart = false
	_knockback_cooldown.wait_time = 0.1
	add_child(_knockback_cooldown)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	if player == null or not _knockback_cooldown.is_stopped():
		return
		
	if not player in get_overlapping_bodies():
		_push_player_inward(player)
		_knockback_cooldown.start()

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_push_player_inward(body)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body

func _push_player_inward(target_player: Player) -> void:
	var inward_dir := (global_position - target_player.global_position).normalized()
	target_player.velocity = Vector2.ZERO
	target_player.movement_component.current_knockback = inward_dir * knockback_strength
	
	var dmg := DamageSource.new(
		boundary_damage,
		0.0,
		DamageSource.DamageSourceType.AUTO_DAMAGE,
		DamageSource.ShiftColor.NONE,
		self
	)
	EventSystem.player_hit.emit(dmg)
