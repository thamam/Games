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

## Current State
var current_health: int = 100
var current_fuel: int = 0
var current_shields: int = 0
var has_parachute: bool = false
var player_index: int = 0

## Cannon Control
var cannon_angle: float = 45.0  # Degrees
var fire_power: float = 0.5  # 0.0 to 1.0
var min_angle: float = 0.0
var max_angle: float = 180.0

## References
var game_manager: GameManager
var terrain: Terrain

## Visual Components
var body_rect: ColorRect
var cannon_line: Line2D
var health_bar: ProgressBar
var label: Label

const TANK_SIZE = Vector2(20, 12)
const CANNON_LENGTH = 15.0
const FALL_DAMAGE_THRESHOLD = 200.0  # Velocity threshold for damage

func _ready() -> void:
	setup_visuals()
	current_health = max_health

	# Physics properties
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func setup_visuals() -> void:
	"""Create tank visual representation"""
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
	health_bar.value = current_health
	health_bar.show_percentage = false
	add_child(health_bar)

	# Player label
	label = Label.new()
	label.position = Vector2(-15, -35)
	label.add_theme_font_size_override("font_size", 10)
	add_child(label)

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
	if current_fuel <= 0:
		return

	var move_distance = direction * movement_speed * delta
	global_position.x += move_distance
	current_fuel = max(0, current_fuel - abs(int(move_distance)))

	moved.emit(global_position)

func apply_damage(amount: int) -> bool:
	"""Apply damage to tank, returns true if destroyed"""
	# Shields absorb damage first
	if current_shields > 0:
		var shield_absorbed = min(amount, current_shields)
		current_shields -= shield_absorbed
		amount -= shield_absorbed
		print("Shield absorbed %d damage" % shield_absorbed)

	# Apply remaining damage to health
	current_health -= amount
	current_health = max(0, current_health)

	# Update health bar
	if health_bar:
		health_bar.value = current_health

	print("Tank %d health: %d" % [player_index, current_health])

	if current_health <= 0:
		destroy()
		return true

	return false

func heal(amount: int) -> void:
	"""Heal tank"""
	current_health = min(max_health, current_health + amount)
	if health_bar:
		health_bar.value = current_health

func add_shields(amount: int) -> void:
	"""Add shield points"""
	current_shields += amount
	print("Tank %d shields: %d" % [player_index, current_shields])

func add_fuel(amount: int) -> void:
	"""Add fuel for movement"""
	current_fuel = min(max_fuel, current_fuel + amount)

func add_parachute() -> void:
	"""Give tank a parachute"""
	has_parachute = true

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

func _physics_process(delta: float) -> void:
	"""Handle tank physics"""
	if current_health <= 0:
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
			if has_parachute:
				print("Parachute saved Tank %d!" % player_index)
				has_parachute = false
			else:
				var damage = int((impact_speed - FALL_DAMAGE_THRESHOLD) / 10)
				print("Tank %d took %d fall damage" % [player_index, damage])
				apply_damage(damage)

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
		current_health,
		current_shields,
		current_fuel
	]
