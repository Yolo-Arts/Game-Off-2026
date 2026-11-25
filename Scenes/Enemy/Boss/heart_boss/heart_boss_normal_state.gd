class_name HeartBossNormalState extends BaseState

var _boss: HeartBoss
var _beat_timer: float = 0.0
var _shift_timer: float = 0.0

func _ready() -> void:
	if id.is_empty():
		id = &"normal"
	super._ready()

func _on_owner_set() -> void:
	_boss = handled_node as HeartBoss

func enter(_data: Variant) -> void:
	if _boss == null:
		return
	if _boss.movement_component is HeartBossMovementComponent:
		_boss.movement_component.is_frozen = false
	
	if _beat_timer <= 0.0:
		_beat_timer = _boss.get_current_beat_interval()
	if _shift_timer <= 0.0:
		_shift_timer = _boss.get_current_shift_interval()

func process_state(delta: float) -> StringName:
	if _boss == null or _boss.dead:
		return NO_STATE
	
	# attack timer
	_beat_timer -= delta
	if _beat_timer <= 0.0:
		_boss.trigger_heartbeat()
		_beat_timer = _boss.get_current_beat_interval()
	
	# doesn't attack while shifting colors.
	if not _boss.is_shifting_color:
		_shift_timer -= delta
		if _shift_timer <= 0.0:
			_boss.start_color_shift()
			_shift_timer = _boss.get_current_shift_interval()
	
	return NO_STATE
