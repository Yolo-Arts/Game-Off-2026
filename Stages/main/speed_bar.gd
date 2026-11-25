extends TextureProgressBar

@export var player : Player
#@onready var player = %Player
@export var indicator_color: Color = Color.GREEN
@export var line_width: float = 4.0
var min_ram_speed_indicator: float = 0.0:
	set(value):
		min_ram_speed_indicator = value
		queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventSystem.stat_changed.connect(setVals)
	EventSystem.player_spawned.connect(setup.unbind(1))

func setup() -> void:
	max_value = player.get_current_stats().max_speed
	min_ram_speed_indicator = player.get_current_stats().minimum_ram_speed

func setVals(stat : String) -> void: 
	if(stat == "max_speed"):
		max_value = player.get_current_stats().max_speed
	if(stat == "minimum_ram_speed"):
		min_ram_speed_indicator = player.get_current_stats().minimum_ram_speed
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = sqrt(pow(player.velocity.y ,2) + pow(player.velocity.x,2))
	tint_progress = lerp(Color.ALICE_BLUE, Color.ORANGE_RED, value / max_value)
	
func _draw() -> void:
	var line_begin: Vector2 = Vector2(size.x / max_value * min_ram_speed_indicator, 0)
	var line_end: Vector2 = Vector2(size.x / max_value * min_ram_speed_indicator, size.y)
	draw_line(line_begin, line_end, indicator_color, line_width)
