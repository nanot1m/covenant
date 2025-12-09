extends Node
class_name HealthComponent

signal health_changed(current_health: float, max_health: float)
signal health_depleted
signal damage_taken(amount: float)
signal healed(amount: float)

@export var max_health: float = 100.0
@export var current_health: float = 100.0

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	var old_health := current_health
	current_health = max(0, current_health - amount)

	damage_taken.emit(amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0 and old_health > 0:
		health_depleted.emit()

func heal(amount: float) -> void:
	var old_health := current_health
	current_health = min(max_health, current_health + amount)

	if current_health > old_health:
		healed.emit(amount)
		health_changed.emit(current_health, max_health)

func get_health_percentage() -> float:
	return current_health / max_health if max_health > 0 else 0.0

func is_alive() -> bool:
	return current_health > 0

func set_max_health(new_max: float) -> void:
	max_health = new_max
	current_health = min(current_health, max_health)
	health_changed.emit(current_health, max_health)
