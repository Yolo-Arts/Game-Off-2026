class_name ItemData
extends Resource

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var modifiers: Array[StatModifier] = []
@export var effect_scene: PackedScene

@export_group("skill tree stuff")
@export var max_level: int = 1
@export var base_cost: int
@export var cost_growth: float = 1.2

var level: int = 0
var unlocked := false
var parents: Array[ItemData] = []
var children: Array[ItemData] = []

func cost() -> int:
	return int(base_cost * pow(cost_growth, level))

func is_maxed() -> bool:
	return level >= max_level

func try_unlock() -> void:
	for p in parents:
		if p.level == 0:
			return
	unlocked = true

func get_stats_display_string() -> String:
	var stat_string: String = ""
	
	for mod in modifiers:
		var mod_string: String = ""
		
		if mod.add != 0.0:
			mod_string = "{value} {stat}\n".format({"value": "%+d" % mod.add, "stat": mod.stat})
		if mod.mult != 1.0:
			mod_string += "{value}x {stat} multiplier\n".format({"value": mod.mult, "stat": mod.stat})
		
		stat_string += mod_string
	return stat_string
