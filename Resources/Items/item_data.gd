class_name ItemData
extends Resource

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var modifiers: Array[StatModifier] = []
@export var effect_scene: PackedScene

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
