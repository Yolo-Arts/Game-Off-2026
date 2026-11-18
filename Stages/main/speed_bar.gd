extends TextureProgressBar

@export var player : Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventSystem.stat_changed.connect(setMax)
	

func setMax(stat : String) -> void: 
	if(stat == "max_speed"):
		max_value = player.get_current_stats().max_speed
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = sqrt(pow(player.velocity.y ,2) + pow(player.velocity.x,2))
	tint_progress = lerp(Color.ALICE_BLUE, Color.ORANGE_RED, value / max_value)
	
