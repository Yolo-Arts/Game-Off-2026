extends Bulletin
@onready var retry_button = %RetryButton
@onready var upgrades_button = %UpgradesButton
@export var gave_over_currency_count_control: PackedScene
@onready var currency_count_container = %currency_count_container
@onready var button_container = %ButtonContainer

func _ready() -> void:
	SaveManager.save_data()
	#Juicee.preset_victory(self)
	retry_button.pressed.connect(retry_pressed)
	upgrades_button.pressed.connect(upgrades_pressed)
	setup_currency_count_container(Currencies.round_data)
	
	setup_ui()
	tween_currencies()
	tween_buttons()


func setup_currency_count_container(dict: Dictionary) -> void:
	for key in dict:
		var gave_over_currency_count_control_scene = gave_over_currency_count_control.instantiate()
		currency_count_container.add_child(gave_over_currency_count_control_scene)
		
		gave_over_currency_count_control_scene.inject_data(dict[key])

func retry_pressed() -> void:
	Currencies.reset_round_data()
	EventSystem.BUL_destroy_all_bulletins.emit()
	EventSystem.STA_change_stage.emit(Globals.current_stage)

func upgrades_pressed() -> void:
	Currencies.reset_round_data()
	EventSystem.BUL_destroy_all_bulletins.emit()
	EventSystem.STA_change_stage.emit(StageConfig.Keys.UpgradeView)

func setup_ui() -> void:
	for button in button_container.get_children():
		button.offset_transform_scale = Vector2.ZERO
		button.visible = false
	
	for currency_count in currency_count_container.get_children():
		currency_count.offset_transform_scale = Vector2.ZERO
		

func tween_currencies() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	
	for currency_count in currency_count_container.get_children():
		currency_count.visible = true
		tween.tween_property(currency_count, "offset_transform_scale", Vector2.ONE, 0.3).from(Vector2.ZERO)
		tween.tween_callback(func(): EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.ItemPickup))
		tween.tween_interval(0.5)

func tween_buttons() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	
	for button in button_container.get_children():
		button.visible = true
		tween.tween_property(button, "offset_transform_scale", Vector2.ONE, 0.3).from(Vector2.ZERO)
		tween.tween_interval(0.5)
