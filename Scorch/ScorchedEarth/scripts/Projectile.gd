extends CharacterBody2D
class_name Projectile

## Projectile - Base class for all weapons
## Handles physics, collision, and explosion

signal exploded(position: Vector2, damage: int, radius: float)
signal hit_tank(tank)

## Projectile Properties
@export var damage: int = 30
@export var explosion_radius: float = 30.0
@export var projectile_color: Color = Color.YELLOW
@export var trail_color: Color = Color.ORANGE
@export var gravity_scale: float = 1.0
@export var wind_resistance: float = 0.5
@export var bounce_factor: float = 0.0  # 0 = no bounce, 0.5 = half velocity, etc.
@export var max_bounces: int = 0
@export var detonation_timer: float = 10.0  # Auto-explode after this time
@export var is_dirt_weapon: bool = false  # If true, adds terrain instead of removing

## Runtime State
var bounces_remaining: int = 0
var time_alive: float = 0.0
var fired_by_player: int = -1
var wind_vector: Vector2 = Vector2.ZERO
var has_exploded: bool = false

## References
var game_manager  # GameManager reference (untyped to avoid circular dependency)
var terrain  # Terrain reference (untyped to avoid circular dependency)

## Visual Components
var sprite: ColorRect
var trail: Line2D
var trail_points: Array[Vector2] = []

const MAX_TRAIL_POINTS = 50
const PROJECTILE_SIZE = 4.0

func _ready() -> void:
	setup_visuals()
	bounces_remaining = max_bounces

	# Set up collision
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func setup_visuals() -> void:
	"""Create projectile visual representation"""
	# Projectile sprite
	sprite = ColorRect.new()
	sprite.size = Vector2(PROJECTILE_SIZE, PROJECTILE_SIZE)
	sprite.position = -Vector2(PROJECTILE_SIZE, PROJECTILE_SIZE) / 2
	sprite.color = projectile_color
	add_child(sprite)

	# Trail
	trail = Line2D.new()
	trail.width = 2.0
	trail.default_color = trail_color
	trail.z_index = -1
	get_parent().add_child(trail) if get_parent() else add_child(trail)

func initialize(start_pos: Vector2, start_velocity: Vector2, player: int, mgr, terr) -> void:  # mgr=GameManager, terr=Terrain (untyped to avoid circular dependency)
	"""Initialize projectile with starting conditions"""
	global_position = start_pos
	velocity = start_velocity
	fired_by_player = player
	game_manager = mgr
	terrain = terr

	# Get wind from game manager
	if game_manager:
		wind_vector = game_manager.get_wind()

	print("Projectile launched at %.0f,%.0f with velocity %.0f,%.0f" % [
		start_pos.x, start_pos.y, start_velocity.x, start_velocity.y
	])

func _physics_process(delta: float) -> void:
	if has_exploded:
		return

	time_alive += delta

	# Auto-detonate after timer expires
	if time_alive >= detonation_timer:
		explode()
		return

	# Apply gravity
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_scale
	velocity.y += gravity * delta

	# Apply wind
	velocity.x += wind_vector.x * wind_resistance * delta

	# Store previous position for trail
	var previous_pos = global_position

	# Move projectile
	var collision = move_and_collide(velocity * delta)

	# Update trail
	add_trail_point(previous_pos)

	# Check collision
	if collision:
		handle_collision(collision)
	else:
		# Check if hit terrain (pixel-perfect)
		if terrain and terrain.is_solid_at(global_position):
			explode()

func add_trail_point(point: Vector2) -> void:
	"""Add point to trail"""
	trail_points.append(point)

	# Limit trail length
	if trail_points.size() > MAX_TRAIL_POINTS:
		trail_points.pop_front()

	# Update trail visual
	if trail:
		trail.clear_points()
		for p in trail_points:
			trail.add_point(p)

func handle_collision(collision: KinematicCollision2D) -> void:
	"""Handle collision with objects"""
	var collider = collision.get_collider()

	# Check if hit tank (duck typing to avoid circular dependency)
	if collider and collider.has_method("get_health"):
		explode()
		hit_tank.emit(collider)
		return

	# Check if can bounce
	if bounces_remaining > 0:
		bounces_remaining -= 1

		# Reflect velocity
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal) * bounce_factor

		print("Projectile bounced! (%d bounces left)" % bounces_remaining)
	else:
		# No bounces left, explode
		explode()

func explode() -> void:
	"""Trigger explosion"""
	if has_exploded:
		return

	has_exploded = true

	print("💥 Projectile exploded at %.0f,%.0f" % [global_position.x, global_position.y])

	# Destroy terrain
	if terrain:
		terrain.destroy_terrain(global_position, explosion_radius, is_dirt_weapon)

	# Apply damage to nearby tanks
	if game_manager:
		apply_explosion_damage()

	exploded.emit(global_position, damage, explosion_radius)

	# Visual explosion effect would go here
	create_explosion_effect()

	# Clean up
	queue_free()

func apply_explosion_damage() -> void:
	"""Apply damage to all tanks in explosion radius"""
	if not game_manager:
		return

	for i in range(game_manager.tanks.size()):
		var tank = game_manager.tanks[i]
		if not tank or tank.get_health() <= 0:
			continue

		var distance = global_position.distance_to(tank.global_position)

		if distance <= explosion_radius:
			# Calculate damage based on distance (full damage at center, 0 at edge)
			var damage_multiplier = 1.0 - (distance / explosion_radius)
			var actual_damage = int(damage * damage_multiplier)

			if actual_damage > 0:
				print("Tank %d in blast radius! Distance: %.0f, Damage: %d" % [
					i, distance, actual_damage
				])
				game_manager.apply_damage(i, actual_damage, fired_by_player)

func create_explosion_effect() -> void:
	"""Create visual explosion effect"""
	# Simple particle effect using colored circles
	var explosion_particles = Node2D.new()
	explosion_particles.global_position = global_position
	get_tree().root.add_child(explosion_particles)

	# Create expanding circles
	for i in range(5):
		var particle = ColorRect.new()
		var size = (i + 1) * explosion_radius / 2.5
		particle.size = Vector2(size, size)
		particle.position = -particle.size / 2
		particle.color = Color(1.0, 0.6, 0.0, 1.0 - (i * 0.15))
		explosion_particles.add_child(particle)

	# Animate and remove
	await get_tree().create_timer(0.3).timeout
	explosion_particles.queue_free()

	# Clean up trail
	if trail:
		trail.queue_free()

## Weapon-specific subclasses can override these methods

func on_fired() -> void:
	"""Called when projectile is fired (for special weapons)"""
	pass

func update_behavior(delta: float) -> void:
	"""Custom update behavior for special weapons"""
	pass


## Specific weapon types

class MissileProjectile extends Projectile:
	func _init() -> void:
		damage = 30
		explosion_radius = 30.0
		projectile_color = Color.YELLOW


class HeavyMissileProjectile extends Projectile:
	func _init() -> void:
		damage = 70
		explosion_radius = 50.0
		projectile_color = Color.ORANGE


class NukeProjectile extends Projectile:

	func _init() -> void:
		damage = 120
		explosion_radius = 100.0
		projectile_color = Color.RED

	func create_explosion_effect() -> void:
		"""Enhanced explosion for nuke"""
		super.create_explosion_effect()

		# Additional shockwave - detached from projectile lifecycle
		if terrain:
			var shockwave_timer = Timer.new()
			shockwave_timer.wait_time = 0.1
			shockwave_timer.one_shot = false

			var shockwaves_done = 0
			var shockwave_pos = global_position
			var saved_terrain = terrain
			var saved_radius = explosion_radius

			shockwave_timer.timeout.connect(func():
				shockwaves_done += 1
				if not is_instance_valid(saved_terrain) or shockwaves_done > 3:
					shockwave_timer.queue_free()
					return

				var wave_radius = saved_radius * (1.0 + shockwaves_done * 0.3)
				saved_terrain.destroy_terrain(shockwave_pos, wave_radius * 0.3, false)
			)

			get_tree().root.add_child(shockwave_timer)
			shockwave_timer.start()


class MIRVProjectile extends Projectile:

	var split_into_submunitions: bool = false
	var submunition_count: int = 5
	var apex_reached: bool = false
	var apex_height: float = 0.0

	func _init() -> void:
		damage = 20  # Each submunition
		explosion_radius = 25.0
		projectile_color = Color.CYAN

	func _physics_process(delta: float) -> void:
		super._physics_process(delta)

		# Check if reached apex (velocity becomes downward)
		if not apex_reached and velocity.y > 0:
			apex_reached = true
			split_mirv()

	func split_mirv() -> void:
		"""Split into multiple independent warheads"""
		if split_into_submunitions or has_exploded:
			return

		split_into_submunitions = true
		print("MIRV splitting into %d warheads!" % submunition_count)

		# Create submunitions
		var ProjectileScript = load("res://scripts/Projectile.gd")
		for i in range(submunition_count):
			var submunition = ProjectileScript.new()
			submunition.damage = damage
			submunition.explosion_radius = explosion_radius
			submunition.projectile_color = projectile_color

			# Spread submunitions
			var spread_angle = -60 + (i * 120.0 / submunition_count)
			var spread_velocity = Vector2(
				cos(deg_to_rad(spread_angle)),
				sin(deg_to_rad(spread_angle))
			) * 150

			get_parent().add_child(submunition)
			submunition.initialize(
				global_position,
				velocity * 0.3 + spread_velocity,
				fired_by_player,
				game_manager,
				terrain
			)

		# Remove parent projectile
		queue_free()
