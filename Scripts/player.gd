extends CharacterBody2D
class_name Player

func _ready() -> void:
	add_to_group("player")

@export var walk_speed: float = 100.0
@export var max_speed: float = 300.0
@export var accel: float = 1200.0
@export var rotation_speed: float = 20.0;
@export var dash_boost_speed: float = 500.0
@export var dash_cooldown_time: float = 2.0
@export var parry_cooldown_time: float = 0.2
@export var friction: float = 1000.0

var last_direction := Vector2(1.0, 0)
var is_gliding := false
var dash_cooldown: float = 0.0
var parry_cooldown: float = 0.0

@onready var rotatable_objects := $RotatableObjects
@onready var sword := $RotatableObjects/Sword
@onready var fireGroup := $RotatableObjects/FireGroup
@onready var parry_cooldown_meter := $UIElements/ParryCooldownMeter
@onready var health_meter := $UIElements/HealthMeter
@onready var health_component := $HealthComponent

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Update cooldowns
	if dash_cooldown > 0:
		dash_cooldown -= delta
	if parry_cooldown > 0:
		parry_cooldown -= delta

	# Update parry cooldown meter (1.0 = ready, 0.0 = on cooldown)
	parry_cooldown_meter.value = 1.0 - (parry_cooldown / parry_cooldown_time)

	# Update health meter
	health_meter.value = health_component.get_health_percentage()

	# Handle dash (can dash from any state if cooldown is ready)
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0:
		if direction.length() > 0:
			velocity = direction.normalized() * dash_boost_speed
		is_gliding = true
		dash_cooldown = dash_cooldown_time

	if is_gliding:
		if direction.length() == 0:
			velocity = velocity.move_toward(Vector2.ZERO, delta * friction)
		else:
			# If overspeeding, slow down with twice the acceleration
			var decel_rate: float = accel
			if velocity.length() > max_speed:
				decel_rate = accel * 2.0
			velocity = velocity.move_toward(direction * max_speed, delta * decel_rate)
			last_direction = velocity

		if direction.length() == 0 and velocity.length() < 10:
			is_gliding = false
	else:
		velocity = walk_speed * direction
			
	if direction.length():
		last_direction = direction
			
	if not is_gliding && direction.length() > 0:
		rotatable_objects.get_node("AnimatedSprite2D").play("walking")
	else:
		rotatable_objects.get_node("AnimatedSprite2D").play("idle")

	var mouse_pos := get_global_mouse_position()
	var direction_to_mouse := (mouse_pos - global_position).normalized()
	var target_rotation := (direction_to_mouse * Vector2(-1, 1)).angle_to(Vector2(0, -1))
	var angle_diff: float = fposmod(target_rotation - rotatable_objects.rotation + PI, TAU) - PI
	rotatable_objects.rotation += move_toward(0, angle_diff, delta * rotation_speed)
	
	if Input.is_action_just_pressed("parry") and parry_cooldown <= 0:
		sword.hit()
		parry_cooldown = parry_cooldown_time

	fireGroup.visible = is_gliding

	move_and_slide()

func take_damage(amount: float) -> void:
	health_component.take_damage(amount)
