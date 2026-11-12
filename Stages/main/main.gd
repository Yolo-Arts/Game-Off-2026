extends Node2D

@onready var camera = %Camera2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		#Globals.open_pause_menu()
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.PauseMenu)

func _ready() -> void:
	EventSystem.MUS_play_music.emit(MusicConfig.Keys.BGMPlaceHolder2)
	TweenManager.camera = camera

func _unhandled_input(event: InputEvent) -> void:
	if event.keycode == KEY_T:
		var spot := get_global_mouse_position()
		Pickups.spawn(Enums.CurrencyType.GEAR, spot, 5000)
		Pickups.spawn(Enums.CurrencyType.STAR, spot, 1)
