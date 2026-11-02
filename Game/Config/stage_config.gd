class_name StageConfig

enum Keys {
	MainMenu,
	Main,
}

static func get_stage(stage_key:Keys) -> Node:
	return load(STAGE_PATHS[stage_key]).instantiate()

const STAGE_PATHS := {
	Keys.MainMenu: "res://Stages/main_menu/start_screen.tscn",
	Keys.Main: "res://Stages/main/main.tscn",
}
