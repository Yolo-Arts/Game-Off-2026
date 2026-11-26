class_name LarryBossHealthBar extends BossHealthBar

var larry: LarrySrSr

func setup_progress_bar() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	larry = boss as LarrySrSr
	boss_name_label.text = boss_name
	var max_health = larry.boss_size
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
	progress_bar.value = larry.segments_left
