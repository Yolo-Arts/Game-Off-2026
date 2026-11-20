extends Button

signal toggled_state(is_checked: bool)

@onready var texture_rect: TextureRect = $TextureRect

var checked: bool = false
var _check_tween: Tween
var _btn_tween: Tween


func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	setup()


func setup() -> void:
	texture_rect.visible = checked
	texture_rect.scale = Vector2.ONE if checked else Vector2.ZERO


func set_checked(value: bool, animate: bool = false) -> void:
	checked = value
	if animate:
		_animate_checkmark()
	else:
		if _check_tween:
			_check_tween.kill()
		setup()


func _on_pressed() -> void:
	checked = not checked
	_animate_button_press()
	_animate_checkmark()
	toggled_state.emit(checked)


func _animate_checkmark() -> void:
	if _check_tween:
		_check_tween.kill()

	texture_rect.pivot_offset = texture_rect.size * 0.5
	_check_tween = create_tween()

	if checked:
		texture_rect.visible = true
		texture_rect.scale = Vector2(0.2, 0.2)
		_check_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_check_tween.tween_property(texture_rect, "scale", Vector2.ONE, 0.22)
	else:
		_check_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		_check_tween.tween_property(texture_rect, "scale", Vector2.ZERO, 0.15)
		_check_tween.tween_callback(func(): texture_rect.visible = false)


func _animate_button_press() -> void:
	if _btn_tween:
		_btn_tween.kill()

	pivot_offset = size * 0.5
	scale = Vector2(0.85, 0.85)
	var target_scale := Vector2(1.06, 1.06) if is_hovered() else Vector2.ONE

	_btn_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_btn_tween.tween_property(self, "scale", target_scale, 0.35)


func _on_mouse_entered() -> void:
	if _btn_tween:
		_btn_tween.kill()
	pivot_offset = size * 0.5
	_btn_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_btn_tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.1)


func _on_mouse_exited() -> void:
	if _btn_tween:
		_btn_tween.kill()
	pivot_offset = size * 0.5
	_btn_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_btn_tween.tween_property(self, "scale", Vector2.ONE, 0.1)
