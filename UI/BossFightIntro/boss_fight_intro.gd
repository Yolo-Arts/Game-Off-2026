extends Control

@export var boss_name: String
@export var boss_sprite: Texture2D
@export var boss_sprite_scale: Vector2 = Vector2(15.0, 15.0)

@onready var boss_name_label = %BossName
@onready var boss_image = %BossImage
@onready var animation_player = %AnimationPlayer

func _ready() -> void:
	setup()
	
	EventSystem.play_boss_intro_animation.connect(play_animation)

func play_animation() -> void:
	print("Animation play")
	animation_player.play("boss_intro")
	
	await animation_player.animation_finished
	EventSystem.unfreeze_boss.emit()
	queue_free()

func setup() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	if boss_name == null or boss_sprite == null:
		push_error("You forgot to put stuff in the intro inspector for the boss...") 
		return
	
	boss_name_label.text = boss_name
	boss_image.texture = boss_sprite
	boss_image.offset_transform_scale = boss_sprite_scale 
