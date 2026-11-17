class_name DeathScreenFx extends ColorRect

@export var in_duration: float = 0.2
@export var out_duration: float = 1.5

var shader: ShaderMaterial = null

var intensity: float = 0.0

var tweens: Array[Tween] = []

func _ready() -> void :
	shader = material as ShaderMaterial

	hide()

func _process(delta: float) -> void :
	shader.set_shader_parameter("intensity", intensity)

func reset() -> void :
	for t in tweens:
		t.kill()

	var tween: Tween = create_tween()
	tween.tween_property(self, "gradient_offset", 0.0, 0.2)

func animate_in() -> void :
	show()

	for t in tweens:
		t.kill()

	var tween: Tween = create_tween()
	tween.tween_property(self, "intensity", 1.0, in_duration)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN)
	tween.tween_callback( func(): set_process(true))

	tweens.append(tween)

func animate_out() -> void :
	for t in tweens:
		t.kill()

	var tween: Tween = create_tween()
	tween.tween_property(self, "intensity", 0.0, out_duration)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN)
	tween.tween_callback( func(): set_process(false))

	tweens.append(tween)
