class_name damage_number_manager extends Node2D


@export var number_scene: PackedScene
@export var pool_size := 32

var free_nums: Array[damage_number] = []

func _ready() -> void: 
	for i in pool_size: 
		var num: damage_number = number_scene.instantiate()
		num.hide()
		num.complete.connect(_reclaim)
		add_child(num)
		free_nums.append(num)
		

func display_val(val: int, pos: Vector2) -> void: 
	var num: damage_number = free_nums.pop_back() if free_nums else steal_oldest()
	num.show()
	num.display(val)
	num.play(pos)

func _reclaim(n: damage_number) -> void: 
	n.hide()
	free_nums.append(n)
	
func steal_oldest() -> damage_number: 
	var num: damage_number = get_child(0)
	move_child(num,get_child_count() - 1)
	return num;
