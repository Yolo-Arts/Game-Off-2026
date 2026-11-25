extends ItemEffect
class_name DashItemEffect

@export var dash_action: StringName = &"dash" 

var cooldown_timer: Timer
var duration_timer: Timer
var is_dashing: bool = false

func _initialize() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	add_child(cooldown_timer)

	duration_timer = Timer.new()
	duration_timer.one_shot = true
	duration_timer.timeout.connect(end_dash)
	add_child(duration_timer)
	
	EventSystem.dash_unlocked.emit()

func _unhandled_input(event: InputEvent) -> void:
	if player == null or player.is_dead:
		return
	if event.is_action_pressed("dash_action") and can_dash():
		print("Yo")
		start_dash()

func can_dash() -> bool:
	if not is_dashing and cooldown_timer.is_stopped():
		return true
	else:
		return false

func start_dash() -> void:
	var stats: PlayerStats = player.get_current_stats()
	is_dashing = true
	
	cooldown_timer.start(stats.dash_cooldown)
	duration_timer.start(stats.dash_duration)
	
	player.state_machine.request_transition(&"dash")
	
	EventSystem.dash_started.emit(stats.dash_duration)

func end_dash() -> void:
	is_dashing = false
	if not player.is_dead:
		await get_tree().create_timer(0.2).timeout
		player.state_machine.request_transition(&"normal")

func _process(_delta: float) -> void:
	if not cooldown_timer.is_stopped():
		EventSystem.dash_cooldown_updated.emit(cooldown_timer.time_left, cooldown_timer.wait_time)

func _on_cooldown_finished() -> void:
	EventSystem.dash_ready.emit()
