extends Panel

@onready var missile_count_label = %MissileCountLabel
@onready var player: Player = %Player
var missile_component: MissileComponent

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	missile_component = player.missile_component
	
	if missile_component.can_fire_missiles():
		visible = true
	else:
		visible = false
		return
	
	missile_count_label.text = str(missile_component.missile_count)
	EventSystem.missile_fired.connect(update_ui)

func update_ui() -> void:
	TweenManager.shake(self, 1.5, 0.2)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(missile_count_label, "offset_transform_scale", Vector2(1.2, 1.2), 0.1)
	tween.parallel().tween_property(missile_count_label, "modulate", Color.RED, 0.1)
	tween.tween_property(missile_count_label, "offset_transform_scale", Vector2.ONE, 0.1)
	tween.parallel().tween_property(missile_count_label, "modulate", Color.WHITE, 0.1)
	missile_count_label.text = str(missile_component.missile_count)
