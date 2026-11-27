extends Node2D 

func _on_hitbox_body_entered(body: Node2D) -> void:
	
	if body is Player:

		EventSystem.fuel_picked_up.emit()
		queue_free()
	
	return
	
