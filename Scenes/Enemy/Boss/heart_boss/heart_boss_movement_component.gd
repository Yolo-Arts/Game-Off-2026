class_name HeartBossMovementComponent extends EnemyMovementComponent

@export var idle_speed_multiplier: float = 0.25 ## Creep speed between beats
@export var beat_surge_multiplier: float = 2.0  ## Burst speed on each heartbeat
@export var pulse_decay_rate: float = 5.0

var is_frozen: bool = false
var current_multiplier: float = 0.25

func pulse_beat() -> void:
	current_multiplier = beat_surge_multiplier

func _physics_process(delta: float) -> void:
	if is_frozen:
		var cached_speed := current_speed
		current_speed = 0.0
		super._physics_process(delta)
		current_speed = cached_speed
		return
	
	current_multiplier = move_toward(current_multiplier, idle_speed_multiplier, pulse_decay_rate * delta)
	
	var cached_speed := current_speed
	current_speed = cached_speed * current_multiplier
	super._physics_process(delta)
	current_speed = cached_speed
