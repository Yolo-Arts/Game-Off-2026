extends Bulletin
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

var user_prefs: UserPrefs

var open_pause_menu_after_closing = false

func _ready() -> void:
	user_prefs = UserPrefs.load_or_create()
	
	if music_slider:
		music_slider.value = user_prefs.music_volume
	if sfx_slider:
		sfx_slider.value = user_prefs.sfx_volume

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		close_settings()

func initialize(_open_pause_menu_after_closing) -> void:
	open_pause_menu_after_closing = _open_pause_menu_after_closing

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)
	user_prefs.music_volume = value

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < .05)
	user_prefs.sfx_volume = value
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UISFXTest)

func _on_reset_defaults_btn_pressed() -> void:
	music_slider.value = 0.8
	sfx_slider.value = 0.8
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.NormalButtonPressed)

func _on_close_btn_pressed() -> void:
	user_prefs.save()
	close_settings()

func close_settings():
	if music_slider:
		music_slider.value = user_prefs.music_volume
	if sfx_slider:
		sfx_slider.value = user_prefs.sfx_volume
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.NormalButtonPressed)
	#queue_free()
	
	if open_pause_menu_after_closing:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.PauseMenu)
	
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.SettingsMenu)


func _on_save_settings_btn_pressed() -> void:
	user_prefs.music_volume = music_slider.value
	user_prefs.sfx_volume = sfx_slider.value
	user_prefs.save()
