class_name EnemySpawnAnimation extends Node2D

@export var scale_pivot: Node2D = null
@export var rotation_pivot: Node2D = null
@export var fill_sprite: Sprite2D = null
@export var glitch_sprite: Sprite2D = null
@export var zoom_sprite: Sprite2D = null

@export var particles: CPUParticles2D = null

var rotate_spawn: bool = false
var spawn_angle: float = 0.0

var glitch_power: float = 0.1:
	set(value):
		glitch_power = value
		shader.set_shader_parameter("shake_power", value)

var glitch_block_size: float = 18.0:
	set(value):
		glitch_block_size = value
		shader.set_shader_parameter("shake_block_size", value)

var shader_modulate: Color = Color.WHITE:
	set(value):
		shader_modulate = value
		shader.set_shader_parameter("modulate", value)

var shader: ShaderMaterial = null

signal finished

func _ready() -> void:
	shader = glitch_sprite.material.duplicate()
	glitch_sprite.material = shader

func animate(texture_data: EnemySpawnAnimationTextureData, animation_speed: float = 1.0, color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	var start_modulate_time: float = 0.35
	var start_modulate_secondary_time: float = 0.35
	var end_modulate_time: float = 0.2
	var end_delay_time: float = 0.6

	if texture_data == null:
		finished.emit.call_deferred()
		return

	glitch_sprite.texture = texture_data.glitch_texture
	zoom_sprite.texture = texture_data.zoom_texture
	fill_sprite.texture = texture_data.fill_texture
	zoom_sprite.show()
	
	fill_sprite.modulate = color
	rotate_spawn = texture_data.rotate
	
	
	var player : Node2D = get_tree().get_first_node_in_group("player")

	if player && texture_data.rotate:
		look_at(player.global_position)
	else:
		rotation_pivot.rotation = 0.0

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_speed_scale(animation_speed)

	tween.tween_property(zoom_sprite, "scale", Vector2.ONE, start_modulate_secondary_time)\
		.from(Vector2.ONE * 4.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(zoom_sprite, "modulate", MyColors.WHITE, 0.05)\
		.from(MyColors.WHITE)
	tween.tween_callback(zoom_sprite.hide).set_delay(start_modulate_secondary_time)

	tween.tween_property(self, "shader_modulate", MyColors.WHITE, start_modulate_time).from(MyColors.WHITE)

	if particles:
		tween.tween_callback(func(): particles.emitting = true).set_delay(0.05)

	tween.tween_property(self, "glitch_power", 0.1, end_modulate_time)\
		.from(1.0)\
		.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "glitch_block_size", 18.0, end_modulate_time)\
		.from(0.0)

	tween.tween_property(self, "shader_modulate", MyColors.WHITE, end_modulate_time)\
		.from(MyColors.WHITE)\
		.set_delay(end_delay_time)

	tween.tween_property(scale_pivot, "scale", Vector2.ONE * 0.8, 0.1).set_delay(0.55)
	tween.tween_property(scale_pivot, "scale", Vector2.ONE * 1.8, 0.1).set_delay(0.7)

	tween.tween_callback(finished.emit).set_delay(0.8)

	# TODO Add enemy spawn SFX
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.EnemySpawn)
