extends Node2D

@onready var currency_count_container = %CurrencyCountContainer
@export var currency_count_control: PackedScene

func _ready() -> void:
	SaveManager.save_data()
	setup_currency_count_container(Currencies._by_type)

func setup_currency_count_container(dict: Dictionary) -> void:
	for key in dict:
		var currency_count_control_scene = currency_count_control.instantiate() as CurrencyCountControl
		currency_count_container.add_child(currency_count_control_scene)
		
		#currency_count_control_scene._data = Currencies._by_type[key]
		currency_count_control_scene.inject_data(dict[key])


func _on_back_to_main_menu_button_pressed():
	EventSystem.STA_change_stage.emit(StageConfig.Keys.MainMenu)


func _on_play_button_pressed():
	EventSystem.STA_change_stage.emit(StageConfig.Keys.Main)


func _on_increase_currency_pressed():
	Currencies.cheat_add_currency()


func _on_reset_upgrades_pressed() -> void:
	SkillTreeUpgrades.reset()
