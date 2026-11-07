class_name CollectableComponent extends Area2D

# Types of pickups: Fuel, Currency, Batteries
# GO near, pickup 
# PICKUP 


func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	
	if(body.is_in_group("player")): 
		print("Picked up [BLANK]")
