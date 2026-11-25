extends Control

@onready var cooldown_bar = %CooldownBar
@onready var prompt_label = %SpacebarLabel

# TODO Make boost ability scene actually look decent.

func _ready() -> void:
	visible = false
	EventSystem.dash_unlocked.connect(_on_dash_unlocked)
	EventSystem.dash_cooldown_updated.connect(_on_cooldown_updated)
	EventSystem.dash_ready.connect(_on_dash_ready)

func _on_dash_unlocked() -> void:
	visible = true
	_on_dash_ready()

func _on_cooldown_updated(time_remaining: float, total_cooldown: float) -> void:
	cooldown_bar.max_value = total_cooldown
	cooldown_bar.value = total_cooldown - time_remaining
	prompt_label.modulate.a = 0.4

func _on_dash_ready() -> void:
	cooldown_bar.value = cooldown_bar.max_value
	prompt_label.modulate.a = 1.0
