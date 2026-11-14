class_name ItemManager extends Node

var base_stats: PlayerStats
var current_stats: PlayerStats
var collected_items: Array[ItemData] = []

# ItemEffect is basically a logical node that does anything based on conditions of any kind
var active_effects: Array[ItemEffect] = []

# an upgrade that changes during the game
var dynamic_modifiers: Array[StatModifier] = []

func setup(_base_stats: PlayerStats) -> void:
	base_stats = _base_stats
	for item in SkillTreeUpgrades.get_purchased_items():
		add_item(item)
	recalculate()

func register_dynamic_modifier(mod: StatModifier) -> void:
	dynamic_modifiers.append(mod)
 
func unregister_dynamic_modifier(mod: StatModifier) -> void:
	dynamic_modifiers.erase(mod)
	recalculate()

func add_item(item: ItemData) -> void:
	collected_items.append(item)
	recalculate()
	if item.effect_scene:
		var effect = item.effect_scene.instantiate() as ItemEffect
		if effect:
			add_child(effect)
			effect.setup(get_parent())
			active_effects.append(effect)
	
	
func recalculate() -> void:
	current_stats = base_stats.duplicate()
	
	var adds: Dictionary[String, float] = {}
	var mults: Dictionary[String, float] = {}
	
	for item in collected_items:
		var stacks := maxi(item.level, 1)
		for mod in item.modifiers:
			adds[mod.stat] = adds.get(mod.stat, 0.0) + (mod.add * stacks)
			mults[mod.stat] = mults.get(mod.stat, 1.0) * pow(mod.mult, stacks)
		
	for mod in dynamic_modifiers:
		adds[mod.stat] = adds.get(mod.stat, 0.0) + mod.add
		mults[mod.stat] = mults.get(mod.stat, 1.0) * mod.mult
	
	for stat_name in adds.keys():
		if !(stat_name in current_stats):
			push_error("STAT DOESN'T EXIST -> ", stat_name)
			continue
		var base_val = current_stats.get(stat_name)
		var new_val = (base_val + adds.get(stat_name, 0.0)) * mults.get(stat_name, 1.0)
		
		current_stats.set(stat_name, new_val)
		EventSystem.stat_changed.emit(stat_name)
	EventSystem.stats_changed.emit(current_stats)
