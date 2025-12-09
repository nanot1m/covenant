extends Node2D
class_name Sword

@export var swing_duration: float = 0.3
@export var start_angle: float = 45.0  # degrees, right side
@export var end_angle: float = -45.0   # degrees, left side
@export var parry_window: float = 0.2  # Time window for parrying

var is_swinging: bool = false
var swing_time: float = 0.0

@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	rotation_degrees = start_angle

	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)
		hitbox.monitoring = false

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

		# Enable hitbox for parrying
		if hitbox:
			hitbox.monitoring = true

			# Disable after parry window
			await get_tree().create_timer(parry_window).timeout
			if hitbox:
				hitbox.monitoring = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	# Check if it's a bullet by checking if it has the parry method
	if area.has_method("parry") and area.has_method("get") and not area.get("is_parried"):
		# Calculate parry direction towards mouse position
		var mouse_pos: Vector2 = get_global_mouse_position()
		var parry_direction: Vector2 = (mouse_pos - area.global_position).normalized()

		# Parry the bullet
		area.call("parry", parry_direction)
