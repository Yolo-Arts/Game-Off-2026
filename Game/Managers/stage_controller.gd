extends Node

func _enter_tree() -> void:
	EventSystem.STA_change_stage.connect(start_stage_change_sequence)

func _ready() -> void:
	change_stage(StageConfig.Keys.MainMenu)

func change_stage(key: StageConfig.Keys) -> void:
	for child in get_children():
		child.queue_free()
	
	var new_stage = StageConfig.get_stage(key)
	add_child(new_stage)

func start_stage_change_sequence(key: StageConfig.Keys) -> void:
	TransitionManager.play_fade_in_black(true)
	await TransitionManager.fade_in_black_animation_player.animation_finished
	change_stage(key)
