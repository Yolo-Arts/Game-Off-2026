extends CharacterBody2D

var speed: float = 200
var acceleration: float = 10
var friction: float = 15

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		velocity = velocity.lerp(speed * direction, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
	
	#if Input.is_action_just_pressed("ui_accept"):
		#TransitionManager.play_red_vignette()
	
	move_and_slide()
