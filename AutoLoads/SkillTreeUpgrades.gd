extends Node

signal changed
signal item_bought(item: ItemData)

const ITEM_PATH := "res://Resources/Items/%s.tres"
var active_scene_item_id: String = ""

const TREE = [
	["fuel_1", [
		["gear_shift_1", [
			["gear_shift_2", [
				["gear_shift_3", [
					["gear_shift_4", [
						["gear_shift_5"],
					]],
				]],
				#["DynamicItems/DashSystem/dash_system_item"]
			]],
			#["energy_recharge_1"],
		]],
		["fuel_2", [
			["BossFights/heart_boss_fight", [
				["fuel_3", [
					["fuel_4"],
				]],
			]],
		]],
		["missile_unlock", [
			["missile_count"],
			["missile_damage_1"],
			["missile_explosion_radius_1"],
		]],
		#["BossFights/test_boss_fight_1"],
	]],
	["energy_recharge_1", [
		["energy_recharge_2"],
		["energy_capacity_1", [
			["energy_capacity_2"],
			["energy_regen_1", [
				["shot_cost", [
					["increase_max_pierce"],
					["railgun"],
				]],
			]],
		]],
		["energy_starter_1", [
			["energy_starter_2"],
			["energy_regen_1"],
		]],
	]],
	["beefier_hull", [
		["recoil_decrease", [
			["beefier_hull_2"],
		]],
		["DynamicItems/DashSystem/dash_system_item"],
	]],
	["projectile_damage_1", [
		["DynamicItems/shrapnel_item", [
			["shrapnel_count_1"],
			["shrapnel_damage"],
		]],
		["projectile_damage_2", [
			["DynamicItems/firball_item", [
				["luckitem"]
			]],
			["projectile_damage_3"],
			["crit_chance_1", [
				["crit_damage_1", [
					["crit_damage_2"],
				]],
				["crit_chance_2"],
			]],
		]],
		["fire_rate", [
			["unlock_right_turret", [
				["unlock_left_turret", [
					["BossFights/larry_sr_sr"]
				]],
			]],
		]],
	]],
	["currency_gear_value_1", [
		["currency_gear_value_2", [
			["BossFights/test_boss_fight_1", [
				["ram_projectile_fuel_increase_1"],
				["ram_projectile_energy_increase_1"],
				["Enemy/projectile_enemy_hp_increase"],
			]],
			["currency_gear_value_3"],
			["Enemy/gold_enemy_item", [
				["Enemy/gold_enemy_spawn_chance", [
					["Enemy/gold_enemy_drop_amount"],
				]],
				["currency_star_value_1", [
					["Enemy/gold_enemy_drop_amount"],
				]],
			]],
		]],
		["currency_range_pickup_1", [
					["currency_range_pickup_2"],
		]], 
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


func start_scene_item(item: ItemData) -> bool:
	if not item.unlocked:
		return false
	
	if not item.get_prices().is_empty():
		if not Currencies.try_spend(item.get_prices()):
			return false
		SaveManager.save_data()
	
	active_scene_item_id = item.id
	return true


func complete_active_scene_item() -> void:
	if active_scene_item_id.is_empty():
		return

	var item := get_item(active_scene_item_id)
	active_scene_item_id = ""

	if item == null or item.is_maxed():
		return

	item.level += 1

	for child in item.children:
		child.try_unlock()

	item_bought.emit(item)
	changed.emit()
	SaveManager.save_data()

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
