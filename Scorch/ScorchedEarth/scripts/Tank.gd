extends CharacterBody2D
class_name Tank

## Tank - Player controllable tank with cannon, movement, and damage system

signal fired(weapon_type: String, angle: float, power: float)
signal destroyed()
signal moved(new_position: Vector2)

## Tank Properties
@export var tank_color: Color = Color.RED
@export var max_health: int = 100
@export var movement_speed: float = 50.0
@export var max_fuel: int = 100

## State (Note: GameManager is the single source of truth)
## These are read from GameManager.players[player_index]
var player_index: int = 0

## Cannon Control
var cannon_angle: float = 45.0  # Degrees
var fire_power: float = 0.5  # 0.0 to 1.0
var min_angle: float = 0.0
var max_angle: float = 180.0

## References
var game_manager  # GameManager reference (untyped to avoid circular dependency)
var terrain  # Terrain reference (untyped to avoid circular dependency)

## Visual Components
var body_rect: ColorRect
var cannon_line: Line2D
var health_bar: ProgressBar
var label: Label
var shield_effect: ColorRect  # Shield visual indicator
var damage_smoke: CPUParticles2D  # Smoke when damaged
var movement_dust: CPUParticles2D  # Dust when moving

const TANK_SIZE = Vector2(20, 12)
const CANNON_LENGTH = 15.0
const FALL_DAMAGE_THRESHOLD = 200.0  # Velocity threshold for damage

func _ready() -> void:
	setup_visuals()

	# Physics properties
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

## Helper functions to get state from GameManager (single source of truth)

func get_player_data() -> Dictionary:
	"""Get player data from GameManager"""
	if game_manager:
		return game_manager.get_player_by_index(player_index)
	return {}

func get_health() -> int:
	"""Get current health from GameManager"""
	return get_player_data().get("health", 0)

func get_shields() -> int:
	"""Get current shields from GameManager"""
	return get_player_data().get("shields", 0)

func get_fuel() -> int:
	"""Get current fuel from GameManager"""
	return get_player_data().get("fuel", 0)

func get_parachute() -> bool:
	"""Check if has parachute from GameManager"""
	return get_player_data().get("parachutes", 0) > 0

func setup_visuals() -> void:
	"""Create tank visual representation"""
	# Collision shape (must be added first for CharacterBody2D)
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = TANK_SIZE
	collision_shape.shape = shape
	add_child(collision_shape)

	# Tank body
	body_rect = ColorRect.new()
	body_rect.size = TANK_SIZE
	body_rect.position = -TANK_SIZE / 2
	body_rect.color = tank_color
	add_child(body_rect)

	# Cannon
	cannon_line = Line2D.new()
	cannon_line.width = 3.0
	cannon_line.default_color = tank_color.darkened(0.3)
	cannon_line.add_point(Vector2.ZERO)
	cannon_line.add_point(Vector2.RIGHT * CANNON_LENGTH)
	add_child(cannon_line)

	update_cannon_visual()

	# Health bar (above tank)
	health_bar = ProgressBar.new()
	health_bar.size = Vector2(30, 5)
	health_bar.position = Vector2(-15, -20)
	health_bar.max_value = max_health
	health_bar.value = max_health  # Will be updated from GameManager
	health_bar.show_percentage = false
	add_child(health_bar)

	# Player label
	label = Label.new()
	label.position = Vector2(-15, -35)
	label.add_theme_font_size_override("font_size", 10)
	add_child(label)

	# Shield effect (animated force field)
	shield_effect = ColorRect.new()
	shield_effect.size = TANK_SIZE * 1.8  # Larger than tank
	shield_effect.position = -(TANK_SIZE * 1.8) / 2
	shield_effect.color = Color(0.3, 0.6, 1.0, 0.0)  # Cyan, initially transparent
	shield_effect.z_index = 1
	shield_effect.visible = false
	add_child(shield_effect)

	# Damage smoke particles
	damage_smoke = CPUParticles2D.new()
	damage_smoke.emitting = false
	damage_smoke.amount = 15
	damage_smoke.lifetime = 1.0
	damage_smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	damage_smoke.emission_rect_extents = TANK_SIZE / 2
	damage_smoke.direction = Vector2(0, -1)
	damage_smoke.spread = 30
	damage_smoke.gravity = Vector2(0, -30)
	damage_smoke.initial_velocity_min = 20
	damage_smoke.initial_velocity_max = 40
	damage_smoke.scale_amount_min = 2.0
	damage_smoke.scale_amount_max = 4.0
	damage_smoke.color = Color(0.2, 0.2, 0.2, 0.5)
	var smoke_gradient = Gradient.new()
	smoke_gradient.set_color(0, Color(0.3, 0.3, 0.3, 0.6))
	smoke_gradient.set_color(1, Color(0.1, 0.1, 0.1, 0.0))
	damage_smoke.color_ramp = smoke_gradient
	add_child(damage_smoke)

	# Movement dust particles
	movement_dust = CPUParticles2D.new()
	movement_dust.emitting = false
	movement_dust.amount = 10
	movement_dust.lifetime = 0.4
	movement_dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	movement_dust.position = Vector2(0, TANK_SIZE.y / 2)  # Bottom of tank
	movement_dust.direction = Vector2(0, 1)
	movement_dust.spread = 45
	movement_dust.gravity = Vector2(0, 50)
	movement_dust.initial_velocity_min = 30
	movement_dust.initial_velocity_max = 50
	movement_dust.scale_amount_min = 1.0
	movement_dust.scale_amount_max = 2.0
	movement_dust.color = Color(0.6, 0.5, 0.4, 0.6)  # Dusty brown
	var dust_gradient = Gradient.new()
	dust_gradient.set_color(0, Color(0.6, 0.5, 0.4, 0.6))
	dust_gradient.set_color(1, Color(0.5, 0.4, 0.3, 0.0))
	movement_dust.color_ramp = dust_gradient
	add_child(movement_dust)

func set_player_info(index: int, player_name: String, color: Color) -> void:
	"""Set tank player information"""
	player_index = index
	tank_color = color

	if body_rect:
		body_rect.color = color
	if cannon_line:
		cannon_line.default_color = color.darkened(0.3)
	if label:
		label.text = player_name
		label.add_theme_color_override("font_color", color)

func update_cannon_visual() -> void:
	"""Update cannon line position based on angle"""
	if not cannon_line:
		return

	var angle_rad = deg_to_rad(cannon_angle)
	var cannon_end = Vector2(cos(angle_rad), -sin(angle_rad)) * CANNON_LENGTH

	cannon_line.set_point_position(1, cannon_end)

func set_cannon_angle(angle: float) -> void:
	"""Set cannon angle in degrees (0-180)"""
	cannon_angle = clamp(angle, min_angle, max_angle)
	update_cannon_visual()

func adjust_cannon_angle(delta_angle: float) -> void:
	"""Adjust cannon angle by delta"""
	set_cannon_angle(cannon_angle + delta_angle)

func set_fire_power(power: float) -> void:
	"""Set fire power (0.0 to 1.0)"""
	fire_power = clamp(power, 0.0, 1.0)

func adjust_fire_power(delta_power: float) -> void:
	"""Adjust fire power by delta"""
	set_fire_power(fire_power + delta_power)

func get_cannon_tip_position() -> Vector2:
	"""Get world position of cannon tip"""
	var angle_rad = deg_to_rad(cannon_angle)
	var cannon_end = Vector2(cos(angle_rad), -sin(angle_rad)) * CANNON_LENGTH
	return global_position + cannon_end

func get_fire_velocity() -> Vector2:
	"""Calculate initial velocity for projectile based on angle and power"""
	var angle_rad = deg_to_rad(cannon_angle)
	var max_velocity = 500.0  # Maximum projectile speed
	var speed = max_velocity * fire_power

	return Vector2(cos(angle_rad), -sin(angle_rad)) * speed

func fire(weapon_type: String = "missile") -> void:
	"""Fire the currently selected weapon"""
	fired.emit(weapon_type, cannon_angle, fire_power)

	# Visual feedback (recoil animation could go here)
	print("Tank %d fired %s" % [player_index, weapon_type])

func move_tank(direction: float, delta: float) -> void:
	"""Move tank left or right using fuel"""
	var fuel = get_fuel()
	if fuel <= 0:
		return

	var move_distance = direction * movement_speed * delta
	global_position.x += move_distance

	# Update fuel in GameManager
	var fuel_used = abs(int(move_distance))
	if game_manager:
		var player_data = get_player_data()
		player_data["fuel"] = max(0, fuel - fuel_used)

	# Emit movement dust particles
	if movement_dust and is_on_floor():
		movement_dust.emitting = true

	moved.emit(global_position)

func apply_damage(amount: int) -> bool:
	"""Apply damage via GameManager (single source of truth)"""
	if game_manager:
		game_manager.apply_damage(player_index, amount)

		# Update health bar visual
		update_health_bar()

		return get_health() <= 0

	return false

func update_health_bar() -> void:
	"""Update health bar and damage visuals from GameManager state"""
	var health = get_health()
	if health_bar:
		health_bar.value = health

	# Update damage state visuals
	var health_percent = float(health) / max_health

	if body_rect:
		# Color shift based on health (pristine → damaged → critical)
		if health_percent > 0.66:  # Pristine (>66%)
			body_rect.color = tank_color
			damage_smoke.emitting = false
		elif health_percent > 0.33:  # Damaged (33-66%)
			body_rect.color = tank_color.lerp(Color.DARK_GRAY, 0.3)
			damage_smoke.emitting = true
		else:  # Critical (<33%)
			body_rect.color = tank_color.lerp(Color.DARK_RED, 0.5)
			damage_smoke.emitting = true
			damage_smoke.amount = 25  # More smoke when critical

func heal(amount: int) -> void:
	"""Heal tank via GameManager"""
	if game_manager:
		var player_data = get_player_data()
		player_data["health"] = min(max_health, player_data.get("health", 0) + amount)
		update_health_bar()

func add_shields(amount: int) -> void:
	"""Add shield points via GameManager"""
	if game_manager:
		var player_data = get_player_data()
		player_data["shields"] = player_data.get("shields", 0) + amount
		print("Tank %d shields: %d" % [player_index, player_data["shields"]])

func add_fuel(amount: int) -> void:
	"""Add fuel for movement via GameManager"""
	if game_manager:
		var player_data = get_player_data()
		player_data["fuel"] = min(max_fuel, player_data.get("fuel", 0) + amount)

func add_parachute() -> void:
	"""Give tank a parachute via GameManager"""
	if game_manager:
		var player_data = get_player_data()
		player_data["parachutes"] = player_data.get("parachutes", 0) + 1

func destroy() -> void:
	"""Destroy this tank"""
	print("Tank %d destroyed!" % player_index)

	# Visual: explosion effect would go here

	destroyed.emit()

	# Hide tank
	if body_rect:
		body_rect.visible = false
	if cannon_line:
		cannon_line.visible = false
	if health_bar:
		health_bar.visible = false

func _process(_delta: float) -> void:
	"""Update visual effects"""
	update_shield_visual()
	update_movement_dust()

func update_shield_visual() -> void:
	"""Animate shield effect with pulsing"""
	var shields = get_shields()

	if shields > 0 and shield_effect:
		shield_effect.visible = true
		# Pulsing alpha animation
		var time = Time.get_ticks_msec() / 1000.0
		var pulse = (sin(time * 4.0) + 1.0) / 2.0  # Oscillates 0-1
		var alpha = 0.2 + (pulse * 0.3)  # Range: 0.2-0.5
		shield_effect.color.a = alpha
	elif shield_effect:
		shield_effect.visible = false

func update_movement_dust() -> void:
	"""Stop movement dust when not moving"""
	if movement_dust and movement_dust.emitting:
		# Check if tank is actually moving
		if abs(velocity.x) < 5.0:  # Threshold for "stopped"
			movement_dust.emitting = false

func _physics_process(delta: float) -> void:
	"""Handle tank physics"""
	if get_health() <= 0:
		return

	# Apply gravity
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	# Check if on ground
	var was_on_ground = is_on_floor()
	move_and_slide()

	# Check for fall damage
	if not was_on_ground and is_on_floor():
		var impact_speed = abs(velocity.y)
		if impact_speed > FALL_DAMAGE_THRESHOLD:
			# Check parachute from GameManager state
			if get_parachute():
				print("Parachute saved Tank %d!" % player_index)
				# Use parachute (decrement in GameManager)
				if game_manager:
					var player_data = get_player_data()
					player_data["parachutes"] = max(0, player_data.get("parachutes", 0) - 1)
			else:
				var damage = int((impact_speed - FALL_DAMAGE_THRESHOLD) / 10)
				print("Tank %d took %d fall damage" % [player_index, damage])
				if game_manager:
					game_manager.apply_damage(player_index, damage)

	# Settle on terrain if on ground
	if is_on_floor():
		velocity.x *= 0.8  # Friction
		velocity.y = 0

## Input handling for human players

func handle_input(delta: float) -> void:
	"""Handle player input (called by game manager)"""
	# Angle adjustment
	if Input.is_action_pressed("ui_left"):
		adjust_cannon_angle(50.0 * delta)
	if Input.is_action_pressed("ui_right"):
		adjust_cannon_angle(-50.0 * delta)

	# Power adjustment
	if Input.is_action_pressed("ui_up"):
		adjust_fire_power(0.5 * delta)
	if Input.is_action_pressed("ui_down"):
		adjust_fire_power(-0.5 * delta)

	# Movement
	if Input.is_action_pressed("move_left"):
		move_tank(-1.0, delta)
	if Input.is_action_pressed("move_right"):
		move_tank(1.0, delta)

	# Fire
	if Input.is_action_just_pressed("fire"):
		fire()

func get_status_text() -> String:
	"""Get status text for display"""
	return "Angle: %.0f° | Power: %.0f%% | Health: %d | Shields: %d | Fuel: %d" % [
		cannon_angle,
		fire_power * 100,
		get_health(),
		get_shields(),
		get_fuel()
	]
