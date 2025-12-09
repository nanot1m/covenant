extends Area2D
class_name Bullet

@export var speed: float = 300.0
@export var damage: float = 10.0
@export var lifetime: float = 5.0

var velocity: Vector2 = Vector2.ZERO
var is_parried: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += velocity * delta

func launch(direction: Vector2) -> void:
	velocity = direction.normalized() * speed
	rotation = direction.angle()

func parry(parry_direction: Vector2) -> void:
	if is_parried:
		return

	is_parried = true
	velocity = parry_direction.normalized() * speed * 1.5
	rotation = parry_direction.angle()

	# Change collision layer so it can hit enemies now
	collision_layer = 0
	collision_mask = 4  # Enemy layer

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and is_parried:
		if area.has_method("take_damage"):
			area.take_damage(damage * 2)  # Parried bullets do more damage
		queue_free()
