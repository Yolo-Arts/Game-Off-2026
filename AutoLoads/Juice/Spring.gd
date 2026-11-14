class_name Spring
extends RefCounted

signal updated(value: float)
signal killed

var x: float
var stiffness: float
var dampening: float
var target_x: float
var v: float = 0.0

var autokill: bool = true
var is_killed: bool = false
var realtime: bool = false

var min_val: float = -INF
var max_val: float = INF

var target: Object
var property: NodePath

func _init(_x: float, _stiffness: float, _dampening: float) -> void:
	x = _x
	target_x = _x
	stiffness = _stiffness
	dampening = _dampening

func update(delta: float) -> void:
	if realtime and Engine.time_scale > 0.0:
		delta /= Engine.time_scale
	delta = minf(0.05, delta)
	var a: float = -stiffness * (x - target_x) - dampening * v
	v += a * delta
	x = clampf(x + v * delta, min_val, max_val)
	updated.emit(x)
	if autokill and absf(a) <= 0.0001:
		kill()

func pull(force: float) -> void:
	x += force

func set_range(minimum: float, maximum: float) -> void:
	min_val = minimum
	max_val = maximum

func kill() -> void:
	is_killed = true
	killed.emit()

func attach(_target: Object, _property: NodePath) -> void:
	target = _target
	property = _property

func set_autokill(_autokill: bool) -> void:
	autokill = _autokill

func set_realtime() -> Spring:
	realtime = true
	return self
