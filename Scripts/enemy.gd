extends Area2D
class_name Enemy

@export var max_health: float = 50.0
@export var shoot_interval_min: float = 1.0
@export var shoot_interval_max: float = 3.0
@export var bullet_scene: PackedScene

var current_health: float
var player: Node2D = null
var shoot_timer: float = 0.0

func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")

	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	# Wait 2 seconds before first shot
	if player:
		shoot_timer = 2.0

func _physics_process(delta: float) -> void:
	if not player:
		return

	# Shoot at player
	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_at_player()
		shoot_timer = randf_range(shoot_interval_min, shoot_interval_max)

func shoot_at_player() -> void:
	if not bullet_scene or not player:
		return

	var bullet: Node2D = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = global_position

	var direction: Vector2 = (player.global_position - global_position).normalized()
	bullet.call("launch", direction)

func take_damage(amount: float) -> void:
	current_health -= amount

	# Flash red
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

	if current_health <= 0:
		die()

func die() -> void:
	queue_free()
