extends Bulletin
@onready var credits_container = %CreditsContainer

func _ready() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(credits_container, "offset_transform_scale", Vector2.ONE, 0.4).from(Vector2(1.0, 0.0))

func _on_close_btn_pressed():
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.Credits)
