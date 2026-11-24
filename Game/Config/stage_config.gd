class_name StageConfig

enum Keys {
	MainMenu,
	Main,
	UpgradeView,
	TestBossFight,
	HeartBoss,
}

static func get_stage(stage_key:Keys) -> Node:
	return load(STAGE_PATHS[stage_key]).instantiate()

const STAGE_PATHS := {
	Keys.MainMenu: "res://Stages/main_menu/start_screen.tscn",
	Keys.Main: "res://Stages/main/main.tscn",
	Keys.UpgradeView: "res://Scenes/UpgradeView/upgrade_view.tscn",
	Keys.TestBossFight: "res://Stages/boss_fights/test/test_boss_fight_2.tscn",
	Keys.HeartBoss: "uid://c7nanxoku28we",
}
