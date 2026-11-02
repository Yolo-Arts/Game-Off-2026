class_name SFXConfig

enum Keys {
	MenuBtnPressed,
	NormalButtonPressed,
	UISFXTest,
}

const FILE_PATHS := {
	Keys.MenuBtnPressed: "uid://bddgp4rr8y56e",
	Keys.NormalButtonPressed: "uid://5lr77gteyirm",
	Keys.UISFXTest: "uid://bt5qxyher3fsk",
}

static func get_audio_stream(key:Keys) -> AudioStream:
	return load(FILE_PATHS.get(key))
