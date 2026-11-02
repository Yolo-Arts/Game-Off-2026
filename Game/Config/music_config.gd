class_name MusicConfig

enum Keys {
	BGMPlaceHolder,
	BGMPlaceHolder2,
}

const FILE_PATHS := {
	Keys.BGMPlaceHolder: "uid://c8qwwlsgbawma",
	Keys.BGMPlaceHolder2: "uid://667o5f6jdulq",
}

static func get_audio_stream(key:Keys) -> AudioStream:
	return load(FILE_PATHS.get(key))
