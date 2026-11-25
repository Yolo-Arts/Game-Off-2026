class_name DashState
extends PlayerState

@export var lock_steering: bool = true

@onready var middle_engine_particles = %MiddleEngineParticles
var last_color: DamageSource.ShiftColor

func _init() -> void:
	id = &"dash"

func can_enter() -> bool:
	return player != null and not player.is_dead

func enter(_data: Variant = null) -> void:
	var stats: PlayerStats = player.get_current_stats()

	player.is_boosting = true
	player.can_control_speed = false
	player.can_reduce_health = false
	
	# Optional if we want the boost to only go in one direction
	# Me personally thinks that locking sterring is boring.
	if lock_steering:
		player.can_steer = false
	
	middle_engine_particles.emitting = true
	
	player.movement_component.current_knockback = Vector2.ZERO
	player.movement_component.set_physics_process(false)

	player.health_component.add_invincibility(&"dash")
	last_color = player.shift_color
	player.shift_color = DamageSource.ShiftColor.NONE
	player.velocity = -player.transform.y * stats.dash_speed

func physics_state(_delta: float) -> StringName:
	if player.is_dead:
		return &"frozen"

	if not lock_steering:
		player.look_at(player.get_global_mouse_position())
		player.rotate(PI / 2.0)

	var stats: PlayerStats = player.get_current_stats()
	player.velocity = -player.transform.y * stats.dash_speed
	player.move_and_slide()

	return &""

func exit() -> void:
	player.is_boosting = false
	player.can_control_speed = true
	player.can_steer = true

	player.health_component.remove_invincibility(&"dash")
	
	player.movement_component.dir = Vector2.ZERO
	player.movement_component.set_physics_process(true)
	
	player.shift_color = last_color
	
	#middle_engine_particles.emitting = false
