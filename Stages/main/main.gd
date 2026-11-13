extends Node2D

@export var currency_count_control: PackedScene

@onready var camera = %Camera2D
@onready var currency_count_container = %CurrencyCountContainer


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		#Globals.open_pause_menu()
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.PauseMenu)

func _ready() -> void:
	EventSystem.MUS_play_music.emit(MusicConfig.Keys.BGMPlaceHolder2)
	TweenManager.camera = camera
	setup_currency_count_container(Currencies._by_type)

func setup_currency_count_container(dict: Dictionary) -> void:
	for key in dict:
		var currency_count_control_scene = currency_count_control.instantiate() as CurrencyCountControl
		currency_count_container.add_child(currency_count_control_scene)
		
		#currency_count_control_scene._data = Currencies._by_type[key]
		currency_count_control_scene.inject_data(dict[key])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		var spot := get_global_mouse_position()
		Pickups.spawn(Enums.CurrencyType.GEAR, spot, 40)
		Pickups.spawn(Enums.CurrencyType.STAR, spot, 10)
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.GameOverScreen)
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.GameOverScreen)
