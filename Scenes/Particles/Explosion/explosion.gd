extends Node2D
class_name Particles

@onready var particles = $CPUParticles2D

var active: bool = false
@export var timer: float = 1.0
@export var life_timer: float = 2.0
@export var duration: float = 0.8

func _physics_process(delta: float) -> void:
	life_timer += delta
	if not active:
		return

	timer += delta
	if timer > duration:
		deactivate()

func activate() -> void:
	if life_timer >= 2.0:
		life_timer = 0.0
		timer = 0.0
		active = true
		particles.restart()
		particles.emitting = true

func deactivate() -> void:
	life_timer += 10.0
	active = false
	particles.emitting = false
