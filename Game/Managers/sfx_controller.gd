extends Node
class_name SFXController

@export var initial_pool_size: int = 8
@export var initial_3d_pool_size: int = 16
@export var max_pool_size: int = 64

var _pool: Array[AudioStreamPlayer] = []
var _pool_3d: Array[AudioStreamPlayer3D] = []


func _ready() -> void:
	for i in initial_pool_size:
		_pool.append(_create_player())
	for i in initial_3d_pool_size:
		_pool_3d.append(_create_player_3d())


func _enter_tree() -> void:
	EventSystem.SFX_play_sfx.connect(play_sfx)
	EventSystem.SFX_play_dynamic_sfx.connect(play_dynamic_sfx)


func _exit_tree() -> void:
	if EventSystem.SFX_play_sfx.is_connected(play_sfx):
		EventSystem.SFX_play_sfx.disconnect(play_sfx)
	if EventSystem.SFX_play_dynamic_sfx.is_connected(play_dynamic_sfx):
		EventSystem.SFX_play_dynamic_sfx.disconnect(play_dynamic_sfx)


func play_sfx(key: SFXConfig.Keys, pitch_rand := 0.0) -> void:
	var stream := SFXConfig.get_audio_stream(key)
	if not stream:
		return

	var audio_player := _get_player()
	audio_player.stream = stream
	audio_player.pitch_scale = 1.0 + randf_range(-pitch_rand, pitch_rand)
	audio_player.play()


func play_dynamic_sfx(key: SFXConfig.Keys, position: Vector3, pitch_rand := 0.0) -> void:
	var stream := SFXConfig.get_audio_stream(key)
	if not stream:
		return

	var audio_player := _get_player_3d()
	audio_player.stream = stream
	audio_player.pitch_scale = 1.0 + randf_range(-pitch_rand, pitch_rand)
	audio_player.global_position = position
	audio_player.play()


func _get_player() -> AudioStreamPlayer:
	if _pool.is_empty():
		return _create_player()
	return _pool.pop_back()


func _get_player_3d() -> AudioStreamPlayer3D:
	if _pool_3d.is_empty():
		return _create_player_3d()
	return _pool_3d.pop_back()


func _create_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = &"SFX"
	add_child(player)
	player.finished.connect(_on_player_finished.bind(player))
	return player


func _create_player_3d() -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.bus = &"SFX"
	add_child(player)
	player.finished.connect(_on_player_3d_finished.bind(player))
	return player


func _on_player_finished(player: AudioStreamPlayer) -> void:
	player.stream = null
	if _pool.size() < max_pool_size:
		_pool.append(player)
	else:
		player.queue_free()


func _on_player_3d_finished(player: AudioStreamPlayer3D) -> void:
	player.stream = null
	if _pool_3d.size() < max_pool_size:
		_pool_3d.append(player)
	else:
		player.queue_free()
