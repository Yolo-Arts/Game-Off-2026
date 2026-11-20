extends Bulletin

@onready var resume_btn = %ResumeBtn
@onready var options_btn = %OptionsBtn
@onready var main_menu_btn = %MainMenuBtn
@onready var pause_menu_container = %PauseMenuContainer
@onready var button_container = %ButtonContainer
@onready var paused_lbl = %PausedLbl

func _ready() -> void:
	for button in button_container.get_children():
		button.offset_transform_scale = Vector2.ZERO
		button.visible = true
	animate_pause_menu()
	resume_btn.pressed.connect(_on_resume_btn_pressed)
	options_btn.pressed.connect(_on_options_btn_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_btn_pressed)
	get_tree().paused = true

func animate_pause_menu(reversed: bool = false) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	if !reversed:
		tween.tween_property(paused_lbl, "offset_transform_scale", Vector2.ONE, 0.25).from(Vector2.ZERO)
	else:
		tween.tween_property(paused_lbl, "offset_transform_scale", Vector2.ZERO, 0.25).from(Vector2.ONE)
	animate_buttons(reversed)

func animate_buttons(reversed: bool = false) -> void:
	for button in button_container.get_children():
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		button.visible = true
		if !reversed:
			tween.tween_property(button, "offset_transform_scale", Vector2.ONE, 0.25).from(Vector2.ZERO)
		else:
			tween.tween_property(button, "offset_transform_scale", Vector2.ZERO, 0.25).from(Vector2.ONE)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_on_resume_btn_pressed()

func _on_resume_btn_pressed() -> void:
	animate_pause_menu(true)
	get_tree().paused = false
	await get_tree().create_timer(0.25).timeout
	#EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.NormalButtonPressed)
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.PauseMenu)

func _on_options_btn_pressed() -> void:
	#EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.NormalButtonPressed)
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.SettingsMenu, true)
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.PauseMenu)


func _on_main_menu_btn_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	#EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.MenuBtnPressed)
	EventSystem.STA_change_stage.emit(StageConfig.Keys.MainMenu)
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.PauseMenu)
	EventSystem.BUL_destroy_all_bulletins.emit()
