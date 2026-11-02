extends CanvasLayer

@onready var fade_in_black_animation_player: AnimationPlayer = $AnimationPlayer
@onready var fade_in_black: ColorRect = $FadeInBlack

@onready var iris_transition: ColorRect = $IrisTransition
@onready var iris_transition_player: AnimationPlayer = $IrisTransitionPlayer

@onready var flash: ColorRect = $Flash
@onready var flash_animation: AnimationPlayer = $FlashAnimation

@onready var red_vignette: ColorRect = $RedVignette
@onready var red_vignette_anim_player: AnimationPlayer = $RedVignetteAnimPlayer

func play_fade_in_black(reversed: bool = false) -> void:
	if reversed == false:
		fade_in_black.visible = true
		fade_in_black_animation_player.play("fade_in")
	else:
		fade_in_black.visible = true
		fade_in_black_animation_player.play_backwards("fade_in")
	
	await fade_in_black_animation_player.animation_finished
	fade_in_black.visible = false


func play_iris(reversed: bool = false) -> void:
	iris_transition.visible = true
	if reversed == false:
		iris_transition_player.play("IrisTransition")
	else:
		iris_transition_player.play_backwards("IrisTransition")
	
	await iris_transition_player.animation_finished
	iris_transition.visible = false

func play_flash(reversed: bool = false) -> void:
	
	if reversed == false:
		flash.visible = true
		flash_animation.play("flash")
	else:
		flash.visible = true
		flash_animation.play_backwards("flash")
	
	await flash_animation.animation_finished
	flash.visible = false

func play_red_vignette(reversed: bool = false) -> void:
	if reversed == false:
		red_vignette.visible = true
		red_vignette_anim_player.play("red_vignette")
	else:
		red_vignette.visible = true
		red_vignette_anim_player.play_backwards("red_vignette")
