extends Bulletin
@onready var retry_button = %RetryButton
@onready var upgrades_button = %UpgradesButton



func initialize(prompt) -> void:
	#if prompt is String:
		#prompt_text = "E\n" + prompt
	
	pass

func _ready() -> void:
	SaveManager.save_data()
	retry_button.pressed.connect(retry_pressed)
	upgrades_button.pressed.connect(upgrades_pressed)

func retry_pressed() -> void:
	EventSystem.BUL_destroy_all_bulletins.emit()
	EventSystem.STA_change_stage.emit(StageConfig.Keys.Main)

func upgrades_pressed() -> void:
	EventSystem.BUL_destroy_all_bulletins.emit()
	EventSystem.STA_change_stage.emit(StageConfig.Keys.UpgradeView)
