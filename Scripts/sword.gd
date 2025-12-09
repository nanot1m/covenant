extends Node2D
class_name Sword

@export var swing_duration: float = 0.3
@export var start_angle: float = 45.0  # degrees, right side
@export var end_angle: float = -45.0   # degrees, left side

var is_swinging: bool = false
var swing_time: float = 0.0

func _ready() -> void:
	rotation_degrees = start_angle

func _process(delta: float) -> void:
	if is_swinging:
		swing_time += delta
		var t: float = clamp(swing_time / swing_duration, 0.0, 1.0)
		rotation_degrees = lerp(start_angle, end_angle, t)

		if t >= 1.0:
			is_swinging = false
			# Reset back to start position
			rotation_degrees = start_angle

func hit() -> void:
	if not is_swinging:
		is_swinging = true
		swing_time = 0.0
