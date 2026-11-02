extends Control

var main_tscn = "uid://cqguftua63irx"

func _ready() -> void:
	EventSystem.MUS_play_music.emit(MusicConfig.Keys.BGMPlaceHolder)
	TransitionManager.play_fade_in_black()

func _on_play_btn_pressed() -> void:
	process_mode = PROCESS_MODE_DISABLED
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.MenuBtnPressed)
	EventSystem.STA_change_stage.emit(StageConfig.Keys.Main)


func _on_options_btn_pressed() -> void:
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.MenuBtnPressed)
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.SettingsMenu)

func _on_quit_btn_pressed() -> void:
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.MenuBtnPressed)
	get_tree().quit()
