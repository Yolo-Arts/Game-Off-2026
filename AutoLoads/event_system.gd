extends Node

@warning_ignore_start("unused_signal")

signal BUL_create_bulletin
signal BUL_destroy_bulletin
signal BUL_destroy_all_bulletins

signal STA_change_stage

signal MUS_play_music

signal SFX_play_sfx
signal SFX_play_dynamic_sfx

signal stats_changed(stats: PlayerStats)
signal stat_changed(stat_name: String)

signal health_changed(new_health: float, new_max_health: float)
signal player_healed(amount: float)
signal health_increased(current: float)
signal health_reduced(current: float)

signal player_invincible
signal player_vincible
signal player_dead

# TO DO -> Create a resource for the enemy information and another signal to account knockback
signal player_hit(amount: float, source: Node)
signal player_died
