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

var currency := 100

func can_buy(item: ItemData) -> bool:
	# TODO implement proper currency check
	if item.unlocked and not item.is_maxed() and currency >= item.cost():
		return true
	else:
		return false

func buy(item: ItemData) -> bool:
	if not can_buy(item):
		return false
	
	currency -= item.cost()
	item.level += 1
	
	for child in item.children:
		child.try_unlock()
	
	item_bought.emit(item)
	changed.emit()
	
	return true
