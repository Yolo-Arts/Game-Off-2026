extends Node2D
class_name BossFightTemplateScene

@export var currency_count_control: PackedScene = preload("res://Scenes/UpgradeView/CurrencyCount/currency_count_control.tscn")

@onready var death_screen = %DeathScreen
@onready var hud = %HUD

@onready var camera = %Camera2D
@onready var currency_count_container = %CurrencyCountContainer
@onready var player: Player = %Player


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		#Globals.open_pause_menu()
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.PauseMenu)

func _ready() -> void:
	EventSystem.MUS_play_music.emit(MusicConfig.Keys.BGMPlaceHolder2)
	TweenManager.camera = camera
	
	EventSystem.player_died.connect(player_died)
	
	setup_currency_count_container(Currencies._by_type)
	
	Globals.beat_boss = false

func setup_currency_count_container(dict: Dictionary) -> void:
	for key in dict:
		var currency_count_control_scene = currency_count_control.instantiate() as CurrencyCountControl
		currency_count_container.add_child(currency_count_control_scene)
		
		#currency_count_control_scene._data = Currencies._by_type[key]
		currency_count_control_scene.inject_data(dict[key])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		var spot := get_global_mouse_position()
		Pickups.spawn(Enums.CurrencyType.GEAR, spot, 10)
		Pickups.spawn(Enums.CurrencyType.STAR, spot, 10)

func player_died() -> void:
	death_screen.animate_in()
	hud.hide()
	player.visible = false
	await get_tree().create_timer(1).timeout
	
	death_screen.animate_out()
	
	
	await get_tree().create_timer(1).timeout
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.GameOverScreen)
