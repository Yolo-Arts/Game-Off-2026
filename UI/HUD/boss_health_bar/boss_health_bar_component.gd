class_name BossHealthBar extends Control

@export var boss: Enemy
@export var boss_name: String

@onready var boss_name_label = %BossNameLabel
@onready var progress_bar = %ProgressBar

var progress_bar_default_page_ratio_from_max_value: float = 0.075

func setup_progress_bar() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	boss_name_label.text = boss_name
	var max_health = boss.health_component.max_health
	var paging = max_health * progress_bar_default_page_ratio_from_max_value
	progress_bar.page = paging
	progress_bar.max_value = max_health
	progress_bar.value = max_health
	
func _ready() -> void:
	if !boss:
		push_error("No boss set for the boss healthbar component D: ")
		return
	
	EventSystem.update_boss_healthbar_component.connect(update_boss_healthbar)
	setup_progress_bar()

func update_boss_healthbar() -> void:
	progress_bar.value = boss.health_component.current_health
