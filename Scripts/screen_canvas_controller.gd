extends Node
@onready var crt = %CRT
@onready var glitch = %Glitch

func _ready() -> void:
	EventSystem.crt_setting_applied.connect(hide_show_crt)
	hide_show_crt(Globals.user_prefs.crt_enabled)

func hide_show_crt(checked: bool) -> void:
	match checked:
		true:
			crt.show()
		false:
			crt.hide()
