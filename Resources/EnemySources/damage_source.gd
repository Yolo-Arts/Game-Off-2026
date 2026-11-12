class_name DamageSource extends Resource

enum DamageSourceType {ENEMY, ENVIRONMENT, PROJECTILE, AUTO_DAMAGE, OTHER}
enum ShiftColor {BLUE, RED, NONE}

var damage_type: DamageSourceType = DamageSourceType.OTHER
var shift_color: ShiftColor = ShiftColor.NONE
var source_node: Node2D = null
var damage: float = 0.0
var knockback: float = 0.0
func _init(_damage: float, _knockback: float, _damage_type: DamageSourceType, _shift_color: ShiftColor, _source_node: Node2D = null) -> void:
	damage = _damage
	damage_type = _damage_type
	shift_color = _shift_color
	source_node = _source_node
	knockback = _knockback
