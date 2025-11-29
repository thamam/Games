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
	"""Create visual explosion effect with particle system"""
	var explosion_container = Node2D.new()
	explosion_container.global_position = global_position
	get_tree().root.add_child(explosion_container)

	# Main explosion flash (brief, bright center)
	var flash = ColorRect.new()
	var flash_size = explosion_radius * 2.0
	flash.size = Vector2(flash_size, flash_size)
	flash.position = -flash.size / 2
	flash.color = Color(1.0, 0.9, 0.6, 0.9)  # Bright yellow-white
	flash.z_index = 10
	explosion_container.add_child(flash)

	# Debris particles using CPUParticles2D
	var debris = CPUParticles2D.new()
	debris.emitting = true
	debris.one_shot = true
	debris.explosiveness = 0.9
	debris.amount = int(explosion_radius * 2)  # More particles for bigger explosions
	debris.lifetime = 0.8
	debris.speed_scale = 1.5

	# Emission
	debris.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	debris.emission_sphere_radius = explosion_radius * 0.3

	# Particle appearance
	debris.color = Color(0.6, 0.4, 0.2, 1.0)  # Dirt color (will vary per particle)
	debris.color_ramp = create_debris_color_ramp()

	# Physics
	debris.direction = Vector2(0, -1)
	debris.spread = 180
	debris.gravity = Vector2(0, 980)
	debris.initial_velocity_min = explosion_radius * 8
	debris.initial_velocity_max = explosion_radius * 12
	debris.angular_velocity_min = -360
	debris.angular_velocity_max = 360
	debris.damping_min = 10
	debris.damping_max = 30

	# Scale (debris gets smaller over time)
	debris.scale_amount_min = 2.0
	debris.scale_amount_max = 4.0
	debris.scale_amount_curve = create_debris_scale_curve()

	explosion_container.add_child(debris)

	# Smoke cloud particles
	var smoke = CPUParticles2D.new()
	smoke.emitting = true
	smoke.one_shot = true
	smoke.explosiveness = 0.7
	smoke.amount = int(explosion_radius * 1.5)
	smoke.lifetime = 1.2
	smoke.speed_scale = 0.8

	# Smoke emission
	smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	smoke.emission_sphere_radius = explosion_radius * 0.5

	# Smoke appearance
	smoke.color = Color(0.3, 0.2, 0.15, 0.6)  # Dark brown smoke
	smoke.color_ramp = create_smoke_color_ramp()

	# Smoke physics (rises and spreads)
	smoke.direction = Vector2(0, -1)
	smoke.spread = 45
	smoke.gravity = Vector2(0, -100)  # Negative = rises
	smoke.initial_velocity_min = explosion_radius * 2
	smoke.initial_velocity_max = explosion_radius * 4
	smoke.damping_min = 5
	smoke.damping_max = 15

	# Smoke expands over time
	smoke.scale_amount_min = 4.0
	smoke.scale_amount_max = 8.0
	smoke.scale_amount_curve = create_smoke_scale_curve()

	explosion_container.add_child(smoke)

	# Animate flash fade out quickly
	var flash_timer = get_tree().create_timer(0.05)
	flash_timer.timeout.connect(func():
		if is_instance_valid(flash):
			flash.queue_free()
	)

	# Remove entire explosion container after particles finish
	var cleanup_timer = get_tree().create_timer(1.5)
	cleanup_timer.timeout.connect(func():
		if is_instance_valid(explosion_container):
			explosion_container.queue_free()
	)

	# Clean up trail
	if trail:
		trail.queue_free()

func create_debris_color_ramp() -> Gradient:
	"""Create color gradient for debris particles"""
	var gradient = Gradient.new()
	gradient.set_color(0, Color(0.6, 0.4, 0.2, 1.0))  # Dirt brown
	gradient.set_color(1, Color(0.4, 0.3, 0.2, 0.0))  # Fade to transparent
	return gradient

func create_debris_scale_curve() -> Curve:
	"""Create scale curve for debris (shrinks over time)"""
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1.0))
	curve.add_point(Vector2(0.5, 0.7))
	curve.add_point(Vector2(1, 0.2))
	return curve

func create_smoke_color_ramp() -> Gradient:
	"""Create color gradient for smoke particles"""
	var gradient = Gradient.new()
	gradient.set_color(0, Color(0.4, 0.3, 0.2, 0.7))  # Dark brown smoke
	gradient.set_color(0.5, Color(0.5, 0.4, 0.3, 0.4))  # Lighter
	gradient.set_color(1, Color(0.6, 0.5, 0.4, 0.0))  # Fade out
	return gradient

func create_smoke_scale_curve() -> Curve:
	"""Create scale curve for smoke (expands over time)"""
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0.3))
	curve.add_point(Vector2(0.3, 0.8))
	curve.add_point(Vector2(1, 1.5))
	return curve

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


class FunkyBombProjectile extends Projectile:
	"""Cluster bomb that scatters submunitions on final impact"""

	var cluster_count: int = 8
	var cluster_spread_speed: float = 200.0
	var has_clustered: bool = false

	func _init() -> void:
		damage = 20  # Each submunition
		explosion_radius = 25.0
		projectile_color = Color.MAGENTA
		max_bounces = 3
		bounce_factor = 0.7

	func handle_collision(collision: KinematicCollision2D) -> void:
		"""Override collision handling to cluster on final bounce"""
		var collider = collision.get_collider()

		# Check if hit tank - explode immediately
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

			print("Funky Bomb bounced! (%d bounces left)" % bounces_remaining)
		else:
			# No bounces left - create cluster
			create_cluster()

	func create_cluster() -> void:
		"""Create scattered cluster submunitions"""
		if has_clustered or has_exploded:
			return

		has_clustered = true
		print("Funky Bomb clustering into %d submunitions!" % cluster_count)

		# Create clustered submunitions
		var ProjectileScript = load("res://scripts/Projectile.gd")
		for i in range(cluster_count):
			var submunition = ProjectileScript.new()
			submunition.damage = damage
			submunition.explosion_radius = explosion_radius * 0.8  # Slightly smaller explosions
			submunition.projectile_color = projectile_color
			submunition.detonation_timer = randf_range(0.1, 0.4)  # Short random fuse

			# Random scatter in all directions (360°)
			var scatter_angle = randf_range(0, 360)
			var scatter_velocity = Vector2(
				cos(deg_to_rad(scatter_angle)),
				sin(deg_to_rad(scatter_angle))
			) * randf_range(cluster_spread_speed * 0.7, cluster_spread_speed * 1.3)

			get_parent().add_child(submunition)
			submunition.initialize(
				global_position,
				scatter_velocity,
				fired_by_player,
				game_manager,
				terrain
			)

		# Remove parent projectile
		queue_free()


class GuidedMissileProjectile extends Projectile:
	"""Player-controlled missile with arrow key steering"""

	var thrust_power: float = 300.0
	var turn_rate: float = 100.0
	var fuel_remaining: float = 3.0  # 3 seconds of control

	func _init() -> void:
		damage = 50
		explosion_radius = 40.0
		projectile_color = Color(1.0, 0.8, 0.0)  # Gold
		detonation_timer = 15.0

	func _physics_process(delta: float) -> void:
		if has_exploded:
			return

		time_alive += delta

		# Auto-detonate after timer expires
		if time_alive >= detonation_timer:
			explode()
			return

		# Player control (if fuel remaining)
		if fuel_remaining > 0:
			handle_player_input(delta)
			fuel_remaining -= delta

		# Apply gravity (reduced for missiles)
		var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_scale * 0.5
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

	func handle_player_input(delta: float) -> void:
		"""Apply thrust based on player input"""
		var thrust = Vector2.ZERO

		# Horizontal thrust (left/right)
		if Input.is_action_pressed("ui_left"):
			thrust.x -= thrust_power
		if Input.is_action_pressed("ui_right"):
			thrust.x += thrust_power

		# Vertical thrust (up/down)
		if Input.is_action_pressed("ui_up"):
			thrust.y -= thrust_power
		if Input.is_action_pressed("ui_down"):
			thrust.y += thrust_power

		# Apply thrust to velocity (gradual, not instant)
		velocity += thrust * delta

		# Limit maximum speed
		var max_speed = 600.0
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed


class HeatSeekingProjectile extends Projectile:
	"""Missile that tracks nearest enemy tank"""

	var turn_rate: float = 150.0  # Degrees per second
	var acceleration: float = 200.0  # Thrust toward target
	var tracking_duration: float = 5.0  # How long it tracks
	var target_tank = null

	func _init() -> void:
		damage = 60
		explosion_radius = 45.0
		projectile_color = Color(1.0, 0.3, 0.0)  # Orange-red
		detonation_timer = 15.0

	func _physics_process(delta: float) -> void:
		if has_exploded:
			return

		time_alive += delta

		# Auto-detonate after timer expires
		if time_alive >= detonation_timer:
			explode()
			return

		# Track target (if within tracking duration)
		if time_alive < tracking_duration:
			find_and_track_target(delta)

		# Apply gravity (reduced for missiles)
		var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_scale * 0.3
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

	func find_and_track_target(delta: float) -> void:
		"""Find nearest tank and adjust trajectory toward it"""
		if not game_manager:
			return

		# Find nearest alive enemy tank
		var nearest_tank = null
		var nearest_distance = INF

		for i in range(game_manager.tanks.size()):
			# Skip if it's the firing player or tank is dead
			if i == fired_by_player:
				continue

			var tank = game_manager.tanks[i]
			if not tank or game_manager.players[i].health <= 0:
				continue

			var distance = global_position.distance_to(tank.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_tank = tank

		if not nearest_tank:
			return

		target_tank = nearest_tank

		# Calculate direction to target
		var to_target = (target_tank.global_position - global_position).normalized()

		# Current velocity direction
		var current_dir = velocity.normalized()

		# Gradually rotate toward target (limited turn rate)
		var angle_diff = current_dir.angle_to(to_target)
		var max_turn = deg_to_rad(turn_rate) * delta

		# Clamp rotation
		if abs(angle_diff) > max_turn:
			angle_diff = sign(angle_diff) * max_turn

		# Apply rotation to velocity
		var new_dir = current_dir.rotated(angle_diff)

		# Apply acceleration toward target
		var current_speed = velocity.length()
		current_speed += acceleration * delta

		# Update velocity
		velocity = new_dir * current_speed

		# Limit maximum speed
		var max_speed = 500.0
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
