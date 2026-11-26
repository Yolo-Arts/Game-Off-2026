class_name BossSegment extends Segment

const STATE_DICT: Dictionary[BossPhase, StringName] = {
	BossPhase.ROAM: &"roam", BossPhase.ARENA: &"arena", BossPhase.FINAL: &"final"
	}

enum BossPhase {ROAM, ARENA, FINAL}
var last_roam_state: StringName = ""
var roam_states: Array[StringName] = ["random", "circle", "charge"]

@export var state_machine: StateMachine



var current_phase: BossPhase = BossPhase.ROAM:
	set(value):
		current_phase = value
		change_phase_state()

func take_damage(damage_source: DamageSource, propogating: bool = false) -> void:
	if not propogating:
		
		Juicee.flicker(self, 0.2, Color(1.0, 1.0, 1.0, 0.369), 0.2)
		Juicee.flash(self)
		if (damage_source.damage_type == DamageSource.DamageSourceType.PLAYER):
			EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.PlayerRam)
		
			Juicee.impact_ring(self)
		ObjectPool.spawn(ObjectPool.bullet_impact_scene, global_position)
		health_component.damage_numbers.display_val(damage_source.damage, global_position)
	if behind_segment:
		behind_segment.take_damage(damage_source, true)
		return
	else:
		health_component.take_damage(damage_source, false)
		EventSystem.enemy_hit.emit(self, damage_source)
		if damage_source.source_node:
			var knockback_amount: float = damage_source.knockback * enemy_stats.knockback_resistance
			movement_component.current_knockback = knockback_amount * damage_source.source_node.global_position.direction_to(global_position)
	
	
	


func change_phase_state() -> void:
	state_machine.request_transition(STATE_DICT[current_phase])


func die() -> void:
	if dead:
		return
	dead = true
	if ahead_segment:
		ahead_segment.behind_segment = null
	if behind_segment:
		behind_segment.ahead_segment = null
	segment_destroyed.emit()
	
	#var collectable := load("res://Game/Collectables/collectable.tscn")
	#var test = collectable.instantiate()
	#test.position = position
	#Juicee.preset_explosion(self)
	await get_tree().process_frame
	collision_layer = 0
	collision_mask = 0
	EventSystem.enemy_died.emit(self)
	ObjectPool.spawn(ObjectPool.explosion_scene, global_position)
	
	# TODO Add enemy death SFX
	Pickups.spawn(Enums.CurrencyType.GEAR, global_position, enemy_stats.drop)
	queue_free()
