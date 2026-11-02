class_name BulletinConfig

enum Keys{
	PauseMenu,
	SettingsMenu
}


static func get_bulletin(bulletin_key:Keys) -> Node:
	return load(BULLETIN_PATHS[bulletin_key]).instantiate()


const BULLETIN_PATHS := {
	Keys.PauseMenu : "res://UI/pause_screen.tscn",
	Keys.SettingsMenu : "res://UI/settings_menu.tscn"
}
