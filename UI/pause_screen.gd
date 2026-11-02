extends Bulletin

@onready var resume_btn: Button = %ResumeBtn
@onready var options_btn: Button = %OptionsBtn
@onready var main_menu_btn: Button = %MainMenuBtn

func _ready() -> void:
	resume_btn.pressed.connect(_on_resume_btn_pressed)
	options_btn.pressed.connect(_on_options_btn_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_btn_pressed)
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_on_resume_btn_pressed()
		#

func _on_resume_btn_pressed() -> void:
	get_tree().paused = false
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.NormalButtonPressed)
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.PauseMenu)

func _on_options_btn_pressed() -> void:
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.NormalButtonPressed)
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.SettingsMenu, true)
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.PauseMenu)


func _on_main_menu_btn_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.MenuBtnPressed)
	EventSystem.STA_change_stage.emit(StageConfig.Keys.MainMenu)
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.PauseMenu)
	
