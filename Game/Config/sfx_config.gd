class_name SFXConfig

enum Keys {
	MenuBtnPressed,
	NormalButtonPressed,
	UISFXTest,
	ButtonPressed,
	ButtonHovered,
}

const FILE_PATHS := {
	Keys.MenuBtnPressed: "uid://bddgp4rr8y56e",
	Keys.NormalButtonPressed: "uid://5lr77gteyirm",
	Keys.UISFXTest: "uid://bt5qxyher3fsk",
	#Keys.ButtonPressed: "res://Audio/UIBtnSFX/button_sfx/KEY_PRESS_007.wav",
	Keys.ButtonPressed: "res://Audio/UIBtnSFX/button_sfx/CLICK_003.wav",
	Keys.ButtonHovered: "res://Audio/UIBtnSFX/button_sfx/CLICK_002.wav",
}

static func get_audio_stream(key:Keys) -> AudioStream:
	return load(FILE_PATHS.get(key))
