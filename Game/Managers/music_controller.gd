extends AudioStreamPlayer
class_name MusicController

@export var fade_duration := 1.0

var current_key : MusicConfig.Keys
var tween : Tween

func _enter_tree() -> void:
	EventSystem.MUS_play_music.connect(play_music)

func _ready() -> void:
	bus = "Music"


func play_music(key : MusicConfig.Keys) -> void:
	if current_key == key and playing:
		return
	
	current_key = key
	
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	
	if playing:
		tween.tween_property(self, "volume_db", -80.0, fade_duration)
		tween.tween_callback(_change_stream.bind(key))
	else:
		_change_stream(key)
	
	tween.tween_property(self, "volume_db", 0.0, fade_duration)

func _change_stream(key: MusicConfig.Keys) -> void:
	stream = MusicConfig.get_audio_stream(key)
	play()
