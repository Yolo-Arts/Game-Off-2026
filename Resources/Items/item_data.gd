class_name ItemData
extends Resource

@export var id: String
@export var display_name: String
@export_multiline var description: String = "Something Something Something Upgrade Description"
@export var icon: Texture2D
@export var modifiers: Array[StatModifier] = []
@export var effect_scene: PackedScene

@export_group("skill tree stuff")
@export var max_level: int = 1

# What shape the item node will be in the skill tree.
@export var shape_type: Enums.ShapeType = Enums.ShapeType.SQUARE

# Array of PriceData to store the cost of an item (so it can have more than one currency cost)
@export var price_data_array: Array[PriceData]


var level: int = 0
var unlocked := false
var parents: Array[ItemData] = []
var children: Array[ItemData] = []

# Price in one currency for the next level. 0 means this item doesn't cost that currency.
# Used in price_bar_container.gd to spawn in the price containers. (and when to hide them if it doesn't cost that currency) 
func get_price(type: Enums.CurrencyType) -> int:
	for price_data in price_data_array:
		if price_data.currency == type:
			return price_data.get_cost(level)
	return 0


# {Enums.CurrencyType: int} for the next level, only currencies with a price above 0.
# Different to get_price as this one is used for calculations. get_price for visuals. Don't get mixed.
# Used in buy() in SkillTreeUpgrades.gd autoload.
func get_prices() -> Dictionary:
	var prices := {}
	for price_data in price_data_array:
		var cost = price_data.get_cost(level)
		if cost > 0:
			prices[price_data.currency] = cost
	return prices

func is_maxed() -> bool:
	return level >= max_level

# Sets nodes to be visible or not when opening skill tree based on parent level being at least level 1.
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
