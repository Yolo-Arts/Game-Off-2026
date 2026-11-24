extends BossFightTemplateScene
@onready var boss_fight_intro = %BossFightIntro
@onready var heart_boss = %HeartBoss

func _ready() -> void:
	super()
	player.state_machine.change_state(&"frozen")
	heart_boss.process_mode = Node.PROCESS_MODE_DISABLED
	EventSystem.start_boss_cutscene.emit()
	cutscene()
	Globals.current_stage = StageConfig.Keys.TestBossFight

func cutscene() -> void:
	hud.visible = false
	var tween: Tween = create_tween()
	tween.tween_callback(func(): EventSystem.play_boss_intro_animation.emit())
	tween.tween_await(boss_fight_intro.animation_player.animation_finished)
	tween.tween_interval(0.25)
	tween.tween_property(camera, "position", Vector2(0, 0), 0.5)
	tween.tween_interval(0.25)
	tween.tween_callback(func(): hud.visible = true)
	tween.tween_callback(func(): player.state_machine.change_state(&"normal"))
	tween.tween_callback(func(): heart_boss.process_mode = Node.PROCESS_MODE_INHERIT)
	
