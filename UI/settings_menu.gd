extends Bulletin

@onready var crt_check_button = %CrtCheckButton
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

var user_prefs: UserPrefs
var open_pause_menu_after_closing = false

@onready var panel_container = %PanelContainer

func _ready() -> void:
	animate_panel()
	user_prefs = UserPrefs.load_or_create()
	
	if music_slider:
		music_slider.value = user_prefs.music_volume
	if sfx_slider:
		sfx_slider.value = user_prefs.sfx_volume
	if crt_check_button:
		crt_check_button.set_checked(user_prefs.crt_enabled)
		crt_check_button.toggled_state.connect(_on_crt_check_button_toggled)

func animate_panel(reversed: bool = false) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	if reversed:
		tween.tween_property(panel_container, "offset_transform_scale", Vector2(1.0, 0.0), 0.3).from(Vector2.ONE)
	else:
		tween.tween_property(panel_container, "offset_transform_scale", Vector2.ONE, 0.3).from(Vector2(1.0, 0.0))

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		close_settings()


func initialize(_open_pause_menu_after_closing) -> void:
	open_pause_menu_after_closing = _open_pause_menu_after_closing


func _on_crt_check_button_toggled(is_checked: bool) -> void:
	user_prefs.crt_enabled = is_checked
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.NormalButtonPressed)
	EventSystem.crt_setting_applied.emit(is_checked)


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
	if crt_check_button:
		crt_check_button.set_checked(false, true)
		user_prefs.crt_enabled = true
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.NormalButtonPressed)
	EventSystem.crt_setting_applied.emit(true)
	crt_check_button.set_checked(user_prefs.crt_enabled, true)


func _on_close_btn_pressed() -> void:
	user_prefs.music_volume = music_slider.value
	user_prefs.sfx_volume = sfx_slider.value
	if crt_check_button:
		user_prefs.crt_enabled = crt_check_button.checked
	user_prefs.save()
	close_settings()


func close_settings() -> void:
	if music_slider:
		music_slider.value = user_prefs.music_volume
	if sfx_slider:
		sfx_slider.value = user_prefs.sfx_volume
	if crt_check_button:
		crt_check_button.set_checked(user_prefs.crt_enabled)
	#EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.NormalButtonPressed)
	
	if open_pause_menu_after_closing:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.PauseMenu)
	
	animate_panel(true)
	await get_tree().create_timer(0.3).timeout
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.SettingsMenu)
