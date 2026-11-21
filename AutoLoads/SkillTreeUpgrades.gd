extends Node

signal changed
signal item_bought(item: ItemData)

const ITEM_PATH := "res://Resources/Items/%s.tres"

const TREE = [
	["DynamicItems/firball_item", [
		["luckitem"]
		]],
	["fuel_1", [
		["fuel_2"]
	]],
	["beefier_hull", [
		["beefier_hull_2"],
		["energy_recharge_1"],
	]],
	["gear_shift_1", [
		["gear_shift_2"],
		["energy_recharge_1"],
	]],
	["projectile_damage_1", [
		["projectile_damage_2", [
			["crit_chance_1", [
				["crit_chance_2"],
			]],
			["crit_damage_1", [
				["crit_damage_2"],
			]],
		]],
		["DynamicItems/shrapnel_item", [
			["shrapnel_count_1"]
		]]
	]],
	["currency_range_pickup_1", [
		["currency_gear_value_1", [
			["Enemy/gold_enemy_item", [
				["currency_star_value_1"]
			]],
		]],
		["Enemy/projectile_enemy"],
	]],
]


var items: Dictionary = {}

func _ready() -> void:
	_build_tree()
	SaveManager.data_saved.connect(_on_data_saved)
	SaveManager.data_loaded.connect(_on_data_loaded)

func _build_tree() -> void:
	items.clear()
	for root_node in TREE:
		_parse_tree_node(root_node, null)
	
	for item: ItemData in items.values():
		if item.parents.is_empty():
			item.unlocked = true

func _parse_tree_node(node_data: Array, parent_item: ItemData) -> void:
	var item_id: String = node_data[0]
	var item: ItemData = items.get(item_id)

	if item == null:
		item = load(ITEM_PATH % item_id) as ItemData
		if item == null:
			push_error("Missing ItemData resource at: " + ITEM_PATH % item_id)
			return
		item.id = item_id
		item.parents.clear()
		item.children.clear()
		items[item_id] = item

	if parent_item != null:
		if not item.parents.has(parent_item):
			item.parents.append(parent_item)
		if not parent_item.children.has(item):
			parent_item.children.append(item)

	if node_data.size() > 1:
		for child_node in node_data[1]:
			_parse_tree_node(child_node, item)

func _on_data_saved() -> void:
	SaveManager.data.upgrade_save_data.clear()
	for item_id: String in items:
		var item: ItemData = items[item_id]
		var entry := UpgradeSaveData.new()
		entry.current_level = item.level
		entry.unlocked = item.unlocked
		SaveManager.data.upgrade_save_data[item_id] = entry

func _on_data_loaded() -> void:
	for item_id: String in items:
		var item: ItemData = items[item_id]
		var saved: UpgradeSaveData = SaveManager.data.upgrade_save_data.get(item_id)
		if saved != null:
			item.level = saved.current_level
			item.unlocked = saved.unlocked
		else:
			item.level = 0
			item.unlocked = item.parents.is_empty()
	
	for item: ItemData in items.values():
		item.unlocked = item.parents.is_empty() or item.level > 0
	for item: ItemData in items.values():
		item.try_unlock()

	changed.emit()

func get_item(item_id: String) -> ItemData:
	return items.get(item_id)

func get_purchased_items() -> Array[ItemData]:
	var purchased: Array[ItemData] = []
	for item: ItemData in items.values():
		if item.level > 0:
			purchased.append(item)
	return purchased

func can_buy(item: ItemData) -> bool:
	if item.unlocked and not item.is_maxed() and Currencies.can_afford(item.get_prices()):
		return true
	else:
		return false

func buy(item: ItemData) -> bool:
	if not item.unlocked or item.is_maxed():
		return false

	if not Currencies.try_spend(item.get_prices()):
		return false

	item.level += 1

	for child in item.children:
		child.try_unlock()

	item_bought.emit(item)
	changed.emit()
	SaveManager.save_data()

	return true

func reset() -> void:
	for item in items.values(): 
		item.level = 0
		item.unlocked = false
	
	for entry in TREE:
		var root_item := get_item(entry[0])
		if root_item:
			root_item.unlocked = true 
	
	SaveManager.data.upgrade_save_data.clear()
	SaveManager.save_data()
	changed.emit()
