extends Label


var parent : TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = str(round(parent.value / 20) as int)
	var target_col = lerp(Color.WHITE, Color.ORANGE_RED, parent.value/parent.max_value)
	set("theme_override_colors/font_color", target_col)
	
