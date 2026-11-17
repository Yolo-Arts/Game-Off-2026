class_name SFXConfig

enum Keys {
	MenuBtnPressed,
	NormalButtonPressed,
	UISFXTest,
	ButtonPressed,
	ButtonHovered,
	PlayerShoot,
	PlayerDeath,
	PlayerRam,
	GearCurrencyCollect,
	EnemySpawn,
	
}

const FILE_PATHS := {
	Keys.MenuBtnPressed: "uid://bddgp4rr8y56e",
	Keys.NormalButtonPressed: "uid://5lr77gteyirm",
	Keys.UISFXTest: "uid://bt5qxyher3fsk",
	#Keys.ButtonPressed: "res://Audio/UIBtnSFX/button_sfx/KEY_PRESS_007.wav",
	Keys.ButtonPressed: "res://Audio/UIBtnSFX/button_sfx/CLICK_003.wav",
	Keys.ButtonHovered: "res://Audio/UIBtnSFX/button_sfx/CLICK_002.wav",
	
	Keys.PlayerShoot: "res://Audio/GameSFX/ShootSFX/shoot_sfx.sfxr",
	Keys.PlayerDeath: "res://Audio/GameSFX/Player/player_death.sfxr",
	Keys.PlayerRam: "res://Audio/GameSFX/Player/sfx_player_hit.ogg",
	
	Keys.GearCurrencyCollect: "res://Audio/GameSFX/Pickups/sfx_currency_pickup.ogg",
	Keys.EnemySpawn: "res://Audio/GameSFX/Enemy/sfx_enemy_spawn_small.wav",
}

static func get_audio_stream(key:Keys) -> AudioStream:
	return load(FILE_PATHS.get(key))
