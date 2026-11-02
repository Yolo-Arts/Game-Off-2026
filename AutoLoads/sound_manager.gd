extends Node

# SFX variables
@onready var menu_btn_pressed: AudioStreamPlayer = $SFX/UIBtnSounds/MenuBtnPressed
@onready var normal_btn_pressed: AudioStreamPlayer = $SFX/UIBtnSounds/NormalBtnPressed
@onready var ui_sfx_test: AudioStreamPlayer = $SFX/UIBtnSounds/uiSfxTest

# Music variables
@onready var bgm_placeholder: AudioStreamPlayer = $Music/bgmPlaceholder

#region UI Button SFX

func play_menuBtn():
	menu_btn_pressed.play()

func play_normalBtn():
	normal_btn_pressed.play()

func play_uiSfxTest():
	ui_sfx_test.play()

#endregion


#func play_bgmPlaceholder():
	#if bgm_placeholder:
		#bgm_placeholder.play()
#
#
#var current_bgm: AudioStreamPlayer = bgm_placeholder
#var fade_duration: float = 1.

#func play_BGM():
	#var target_music: AudioStreamPlayer = null
	#
	#match Globals.scene:
		#"Menu":
			#target_music = bgm_placeholder
		##"LevelOne":
			##target_music = level_one
		##"LevelTwo":
			##target_music = level_two
		##"Endless":
			##target_music = endless
	#
	#if target_music != current_bgm:
		#fade_to_music(target_music)

#func fade_to_music(new_bgm: AudioStreamPlayer):
	#var tween = create_tween().set_parallel(true)
	#
	#if current_bgm and current_bgm.playing:
		#tween.tween_property(current_bgm, "volume_db", -80.0, fade_duration)
		#tween.chain().tween_callback(current_bgm.stop)
	#
	#if new_bgm:
		#new_bgm.volume_db = -80.0 
		#new_bgm.play()
		#tween.tween_property(new_bgm, "volume_db", 0.0, fade_duration)
	#
	#current_bgm = new_bgm
