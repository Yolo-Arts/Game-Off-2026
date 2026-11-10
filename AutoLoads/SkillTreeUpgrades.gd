extends Node

signal changed
signal item_bought(item: ItemData)

const ITEM_PATH := "res://Resources/Items/%s.tres"

const TREE = [
	["test_item", [
		["test_item2", [
			["test_item3", [
				["merge_item", [["after_merge_item"]]],
			]],
		]],
		["test_item4", [
			["test_item5", [
				["merge_item"],                            
			]],
			["test_item6"],
		]],
	]],
	["test_item7", [
		["test_item8", [
			["test_item10"]
		]],
		["test_item9", [
			["test_item10"]
		]],
		]],
	#["test_item9", [["test_item10"]]],
	#["test_item11"], 
	#["test_item12"],
	#["test_item13"],
	#["test_item14"],
	#["test_item15"],
	#["test_item16"],
]

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
	
	return true
