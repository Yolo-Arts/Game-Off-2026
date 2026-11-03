class_name StatModifier
extends Resource

@export var stat: String
@export var add: float = 0.0 
@export var mult: float = 1.0

func _init(p_stat: String, p_add: float = 0.0, p_mult: float = 1.0):
	stat = p_stat
	add = p_add
	mult = p_mult
