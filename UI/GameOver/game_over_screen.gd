extends Bulletin
@onready var retry_button = %RetryButton
@onready var upgrades_button = %UpgradesButton
@export var gave_over_currency_count_control: PackedScene
@onready var currency_count_container = %currency_count_container


#func initialize(prompt) -> void:
	##if prompt is String:
		##prompt_text = "E\n" + prompt
	#
	#pass

func _ready() -> void:
	SaveManager.save_data()
	retry_button.pressed.connect(retry_pressed)
	upgrades_button.pressed.connect(upgrades_pressed)
	setup_currency_count_container(Currencies.round_data)

func setup_currency_count_container(dict: Dictionary) -> void:
	for key in dict:
		var gave_over_currency_count_control_scene = gave_over_currency_count_control.instantiate()
		currency_count_container.add_child(gave_over_currency_count_control_scene)
		
		gave_over_currency_count_control_scene.inject_data(dict[key])

func retry_pressed() -> void:
	Currencies.reset_round_data()
	EventSystem.BUL_destroy_all_bulletins.emit()
	EventSystem.STA_change_stage.emit(StageConfig.Keys.Main)

func upgrades_pressed() -> void:
	Currencies.reset_round_data()
	EventSystem.BUL_destroy_all_bulletins.emit()
	EventSystem.STA_change_stage.emit(StageConfig.Keys.UpgradeView)
