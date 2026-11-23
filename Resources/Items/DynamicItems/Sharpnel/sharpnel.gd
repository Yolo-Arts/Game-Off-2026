class_name shrapnel extends Area2D

var damage: float = 0.0
var speed: float = 0.0
var direction: Vector2 = Vector2.ZERO
var timeout: float = 5.0
var knockback: float = 0.0
var timer: float = 0.0
signal done

func setup(_damage: float, _speed: float, _direction: Vector2 = Vector2.INF, _timeout: float = 2.0, _knockback: float = 0.0) -> void:
	damage = _damage
	speed = _speed
	timeout = _timeout
	timer = timeout
	knockback = _knockback
	rotation = randf_range(0, TAU)
	if _direction == Vector2.INF:
		direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		return
	direction  = _direction
	
	
	
func _physics_process(delta: float) -> void:
	global_position += speed * direction * delta
	timer -= delta
	if timer <= 0.0:
		done.emit()
	


func _on_body_entered(body: Node2D) -> void:
	var damage_source := DamageSource.new(damage, knockback, DamageSource.DamageSourceType.PROJECTILE, DamageSource.ShiftColor.NONE, self)
	if body.has_method("take_damage"):
		body.take_damage(damage_source)
	done.emit()
