class_name Enemy extends CharacterBody2D

@onready var health_component: EnemyHealthComponent = $HealthComponent
@onready var movement_component: EnemyMovementComponent = $MovementComponent
# @onready var HitboxComponent : EnemyHitbox = $HitboxComponent




func _ready() -> void:
	health_component.setup(self)
	movement_component.setup(self)
	
func _process(delta: float) -> void:
	
	#For testing and debugging 
	if(Input.is_key_pressed(KEY_O)): 
		health_component.take_damage(5)
	
func _exit_tree() -> void:
	
	var collectable := load("res://Game/Collectables/collectable.tscn")
	var test = collectable.instantiate()
	test.position = position
	
