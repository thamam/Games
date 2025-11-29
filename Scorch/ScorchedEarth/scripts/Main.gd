extends Node2D

## Main Game Scene - Orchestrates all game systems
## Note: All scripts use class_name declarations and are globally available

## Node references (untyped to avoid circular dependencies)
@onready var game_manager = $GameManager  # GameManager
@onready var terrain = $Terrain  # Terrain
@onready var tanks_container: Node2D = $Tanks
@onready var projectiles_container: Node2D = $Projectiles
@onready var ui: Control = $UI

## UI elements
var hud: Control
var status_label: Label
var player_info_label: Label
var wind_indicator: Label
var gravity_indicator: Label  # Gravity event indicator (Phase 2.3)
var angle_label: Label
var power_label: Label
var shop: Control  # Shop UI
var terrain_selector: Control  # Terrain selection UI
var wind_particles: CPUParticles2D  # Wind visual effects (Phase 2.2)

## Game state
var current_weapon  # Weapon
var current_tank  # Tank

## Game configuration (exposed for customization)
@export var num_players: int = 4  # Total players (2-10 per GDD)
@export var num_human_players: int = 1  # Number of human players (rest are AI)
@export var ai_difficulty: int = 1  # Default AI level (0=Lobber, 1=Poolshark, 2=Spoiler)

func _ready() -> void:
	print("=================================")
	print("  SCORCHED EARTH - Godot Remake  ")
	print("=================================\n")

	setup_ui()
	setup_game()

	# Show terrain selector first (Phase 2.1 - Terrain Variety)
	await get_tree().create_timer(0.5).timeout
	if terrain_selector:
		terrain_selector.show_selector()
	else:
		# Fallback: Start game immediately with default theme
		start_new_game()

func setup_ui() -> void:
	"""Setup user interface"""
	if not ui:
		ui = Control.new()
		ui.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(ui)

	# HUD Container
	hud = VBoxContainer.new()
	hud.position = Vector2(10, 10)
	ui.add_child(hud)

	# Status label
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color.WHITE)
	status_label.add_theme_color_override("font_outline_color", Color.BLACK)
	status_label.add_theme_constant_override("outline_size", 2)
	hud.add_child(status_label)

	# Player info
	player_info_label = Label.new()
	player_info_label.add_theme_font_size_override("font_size", 14)
	player_info_label.add_theme_color_override("font_color", Color.YELLOW)
	player_info_label.add_theme_color_override("font_outline_color", Color.BLACK)
	player_info_label.add_theme_constant_override("outline_size", 2)
	hud.add_child(player_info_label)

	# Wind indicator
	wind_indicator = Label.new()
	wind_indicator.add_theme_font_size_override("font_size", 14)
	wind_indicator.add_theme_color_override("font_color", Color.CYAN)
	wind_indicator.add_theme_color_override("font_outline_color", Color.BLACK)
	wind_indicator.add_theme_constant_override("outline_size", 2)
	hud.add_child(wind_indicator)

	# Gravity indicator (Phase 2.3)
	gravity_indicator = Label.new()
	gravity_indicator.add_theme_font_size_override("font_size", 14)
	gravity_indicator.add_theme_color_override("font_color", Color.WHITE)
	gravity_indicator.add_theme_color_override("font_outline_color", Color.BLACK)
	gravity_indicator.add_theme_constant_override("outline_size", 2)
	hud.add_child(gravity_indicator)

	# Control hints
	var hints = Label.new()
	hints.text = "Controls: Arrow Keys (Angle/Power) | SPACE (Fire) | A/D (Move) | 1-9 (Weapon) | TAB (Shop)"
	hints.position = Vector2(10, get_viewport_rect().size.y - 30)
	hints.add_theme_font_size_override("font_size", 12)
	hints.add_theme_color_override("font_color", Color.WHITE)
	hints.add_theme_color_override("font_outline_color", Color.BLACK)
	hints.add_theme_constant_override("outline_size", 1)
	ui.add_child(hints)

	# Shop UI
	var ShopScript = load("res://scripts/Shop.gd")
	shop = ShopScript.new()
	shop.purchase_completed.connect(_on_purchase_completed)
	shop.shop_closed.connect(_on_shop_closed)
	ui.add_child(shop)

	# Terrain Selector UI (Phase 2.1)
	var TerrainSelectorScript = load("res://scripts/TerrainSelector.gd")
	terrain_selector = TerrainSelectorScript.new()
	terrain_selector.theme_selected.connect(_on_terrain_theme_selected)
	terrain_selector.selection_cancelled.connect(_on_terrain_selection_cancelled)
	ui.add_child(terrain_selector)

	# Wind particle effects (Phase 2.2)
	setup_wind_particles()

func setup_wind_particles() -> void:
	"""Setup wind particle effects system (Phase 2.2)"""
	wind_particles = CPUParticles2D.new()

	# Position at top center of screen
	var viewport_size = get_viewport_rect().size
	wind_particles.position = Vector2(viewport_size.x / 2, 50)

	# Emission configuration
	wind_particles.emitting = true
	wind_particles.amount = 30
	wind_particles.lifetime = 3.0
	wind_particles.explosiveness = 0.0
	wind_particles.randomness = 0.3

	# Emission shape - wide horizontal line across screen
	wind_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	wind_particles.emission_rect_extents = Vector2(viewport_size.x / 2, 10)

	# Initial particle appearance
	wind_particles.scale_amount_min = 2.0
	wind_particles.scale_amount_max = 4.0

	# Color - will be updated based on wind
	wind_particles.color = Color(0.9, 0.9, 0.9, 0.6)

	# Gradient for fading
	var particle_gradient = Gradient.new()
	particle_gradient.set_color(0, Color(1, 1, 1, 0.5))
	particle_gradient.set_color(1, Color(0.8, 0.8, 0.8, 0.0))
	wind_particles.color_ramp = particle_gradient

	# Initial direction (will be updated based on wind)
	wind_particles.direction = Vector2(1, 0)
	wind_particles.spread = 5.0
	wind_particles.gravity = Vector2(0, 30)  # Slight downward drift
	wind_particles.initial_velocity_min = 20
	wind_particles.initial_velocity_max = 50

	add_child(wind_particles)

func setup_game() -> void:
	"""Initialize game systems"""
	# Connect game manager signals
	game_manager.turn_started.connect(_on_turn_started)
	game_manager.turn_ended.connect(_on_turn_ended)
	game_manager.game_over.connect(_on_game_over)
	game_manager.round_started.connect(_on_round_started)

	# Assign references
	game_manager.terrain = terrain

func start_new_game(selected_theme: Terrain.TerrainTheme = Terrain.TerrainTheme.MOUNTAINS) -> void:
	"""Start a new game with selected terrain theme"""
	print("Starting new game...")

	# Apply selected terrain theme (Phase 2.1)
	terrain.set_theme(selected_theme)

	# Setup game with configurable players - GDD supports 2-10 players
	# Create AI player array based on configuration
	var ai_players: Array[Dictionary] = []
	var num_ai = max(0, num_players - num_human_players)

	for i in range(num_ai):
		ai_players.append({"level": ai_difficulty})

	print("Game setup: %d players (%d human, %d AI at level %d)" % [
		num_players, num_human_players, num_ai, ai_difficulty
	])

	game_manager.setup_new_game(num_players, ai_players)

	# Spawn tanks
	spawn_tanks()

	# Start first round
	game_manager.start_round()

	# Set default weapon
	var WeaponScript = load("res://scripts/Weapon.gd")
	current_weapon = WeaponScript.create_missile()

func spawn_tanks() -> void:
	"""Spawn tanks for all players"""
	game_manager.tanks.clear()

	# Clear existing tanks
	for child in tanks_container.get_children():
		child.queue_free()

	# Create tank for each player
	var TankScript = load("res://scripts/Tank.gd")
	for i in range(game_manager.num_players):
		var tank = TankScript.new()
		var player = game_manager.players[i]

		# Set tank properties
		tank.set_player_info(i, player.name, player.color)
		tank.game_manager = game_manager
		tank.terrain = terrain

		# Position tank
		var spawn_pos = terrain.find_spawn_position(i, game_manager.num_players)
		tank.global_position = spawn_pos

		# Connect signals
		tank.fired.connect(_on_tank_fired.bind(i))
		tank.destroyed.connect(_on_tank_destroyed.bind(i))

		# Add to scene
		tanks_container.add_child(tank)
		game_manager.tanks.append(tank)

		print("Spawned %s at %.0f,%.0f" % [player.name, spawn_pos.x, spawn_pos.y])

func _on_turn_started(player_index: int) -> void:
	"""Handle turn start"""
	current_tank = game_manager.tanks[player_index]
	var player = game_manager.players[player_index]

	status_label.text = "=== %s's Turn ===" % player.name
	status_label.add_theme_color_override("font_color", player.color)

	print("\n--- %s's Turn ---" % player.name)

	# Open shop for human players at turn start
	if not player.is_ai:
		# Small delay before showing shop
		await get_tree().create_timer(0.3).timeout
		if shop and is_instance_valid(shop):
			shop.open_shop(player_index, game_manager)

func _on_turn_ended(player_index: int) -> void:
	"""Handle turn end"""
	print("Turn ended for player %d" % player_index)

func _on_round_started(round_number: int) -> void:
	"""Handle round start"""
	print("=== Round %d Started ===" % round_number)

func _on_game_over(winner_index: int) -> void:
	"""Handle game over"""
	if winner_index >= 0:
		var winner = game_manager.players[winner_index]
		status_label.text = "🎉 %s WINS! 🎉" % winner.name
		status_label.add_theme_color_override("font_color", winner.color)
	else:
		status_label.text = "DRAW!"

	# Show restart option
	await get_tree().create_timer(3.0).timeout
	print("\nPress R to restart or ESC to quit")

func _on_tank_fired(_weapon_type: String, _angle: float, _power: float, player_index: int) -> void:
	"""Handle tank firing weapon"""
	var tank = game_manager.tanks[player_index]

	# Create projectile
	var projectile = current_weapon.create_projectile()
	projectile.fired_by_player = player_index

	# Add to scene
	projectiles_container.add_child(projectile)

	# Initialize projectile
	var start_pos = tank.get_cannon_tip_position()
	var start_velocity = tank.get_fire_velocity()

	projectile.initialize(start_pos, start_velocity, player_index, game_manager, terrain)

	# Connect projectile signals
	projectile.exploded.connect(_on_projectile_exploded)

	# Wait for projectile to finish
	await projectile.tree_exited

	# Small delay after explosion (check if still in tree)
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout

	# End turn
	game_manager.end_turn()

func _on_projectile_exploded(pos: Vector2, damage: int, radius: float) -> void:
	"""Handle projectile explosion"""
	print("Explosion at %.0f,%.0f (damage: %d, radius: %.0f)" % [
		pos.x, pos.y, damage, radius
	])

func _on_tank_destroyed(player_index: int) -> void:
	"""Handle tank destruction"""
	print("Tank %d destroyed" % player_index)

func _process(_delta: float) -> void:
	"""Update game state and UI"""
	update_ui()
	handle_game_input()

func update_wind_particles(wind: Vector2, wind_strength: String) -> void:
	"""Update wind particle effects based on current wind (Phase 2.2)"""
	if not wind_particles:
		return

	# Set particle direction based on wind
	var wind_direction = 1.0 if wind.x > 0 else -1.0
	wind_particles.direction = Vector2(wind_direction, 0.2)  # Slight downward angle

	# Adjust particle properties based on wind strength
	match wind_strength:
		"Calm":
			wind_particles.amount = 15
			wind_particles.initial_velocity_min = 10
			wind_particles.initial_velocity_max = 30
			wind_particles.color = Color(0.9, 0.95, 1.0, 0.3)  # Faint white-blue
			wind_particles.scale_amount_min = 1.5
			wind_particles.scale_amount_max = 3.0
		"Breeze":
			wind_particles.amount = 30
			wind_particles.initial_velocity_min = 30
			wind_particles.initial_velocity_max = 60
			wind_particles.color = Color(0.8, 0.9, 1.0, 0.4)  # Light blue
			wind_particles.scale_amount_min = 2.0
			wind_particles.scale_amount_max = 4.0
		"Strong":
			wind_particles.amount = 50
			wind_particles.initial_velocity_min = 60
			wind_particles.initial_velocity_max = 100
			wind_particles.color = Color(0.9, 0.85, 0.6, 0.5)  # Dusty yellow
			wind_particles.scale_amount_min = 2.5
			wind_particles.scale_amount_max = 5.0
		"Storm":
			wind_particles.amount = 80
			wind_particles.initial_velocity_min = 100
			wind_particles.initial_velocity_max = 150
			wind_particles.color = Color(0.7, 0.7, 0.7, 0.6)  # Dark gray
			wind_particles.scale_amount_min = 3.0
			wind_particles.scale_amount_max = 6.0

	# Adjust spread based on wind strength (less spread = more directional)
	match wind_strength:
		"Calm":
			wind_particles.spread = 15.0
		"Breeze":
			wind_particles.spread = 10.0
		"Strong":
			wind_particles.spread = 5.0
		"Storm":
			wind_particles.spread = 3.0

func update_ui() -> void:
	"""Update UI elements"""
	var GameManagerScript = load("res://scripts/GameManager.gd")
	if game_manager.current_state == GameManagerScript.GameState.PLAYING:
		var player = game_manager.get_current_player()
		if player.is_empty():
			return

		# Player info
		player_info_label.text = "%s | Health: %d | Money: $%d | Shields: %d" % [
			player.name,
			player.health,
			player.money,
			player.shields
		]

		# Wind (Phase 2.2: Enhanced visual indicator)
		var wind = game_manager.get_wind()
		var wind_strength = game_manager.wind_strength

		# Determine arrow count and color based on wind strength
		var arrow_count = 1
		var wind_color = Color.WHITE

		match wind_strength:
			"Calm":
				arrow_count = 1
				wind_color = Color(0.7, 0.9, 1.0)  # Light blue
			"Breeze":
				arrow_count = 2
				wind_color = Color.CYAN
			"Strong":
				arrow_count = 3
				wind_color = Color(1.0, 0.8, 0.0)  # Orange-yellow
			"Storm":
				arrow_count = 4
				wind_color = Color(1.0, 0.3, 0.3)  # Red

		# Build arrow string based on direction
		var arrow = "←" if wind.x < 0 else "→"
		var arrows = ""
		for i in range(arrow_count):
			arrows += arrow

		wind_indicator.text = "Wind: %s %s (%.0f)" % [wind_strength, arrows, abs(wind.x)]
		wind_indicator.add_theme_color_override("font_color", wind_color)

		# Update wind particles (Phase 2.2)
		update_wind_particles(wind, wind_strength)

		# Gravity indicator (Phase 2.3)
		var gravity_event = game_manager.gravity_event
		var gravity_value = game_manager.current_gravity
		var gravity_color = Color.WHITE
		var gravity_symbol = ""

		match gravity_event:
			"Low":
				gravity_color = Color(0.6, 0.8, 1.0)  # Light blue
				gravity_symbol = "↓"
			"Normal":
				gravity_color = Color.WHITE
				gravity_symbol = "="
			"High":
				gravity_color = Color(1.0, 0.8, 0.4)  # Orange
				gravity_symbol = "↑"
			"Extreme":
				gravity_color = Color(1.0, 0.3, 0.3)  # Red
				gravity_symbol = "↑↑"

		gravity_indicator.text = "Gravity: %s %s (%.0f)" % [gravity_event, gravity_symbol, gravity_value]
		gravity_indicator.add_theme_color_override("font_color", gravity_color)

		# Tank status
		if current_tank and current_tank.get_health() > 0:
			var status = current_tank.get_status_text()
			# Update angle/power display
			if status_label:
				var lines = status_label.text.split("\n")
				if lines.size() > 0:
					status_label.text = lines[0] + "\n" + status

func handle_game_input() -> void:
	"""Handle global input"""
	var GameManagerScript = load("res://scripts/GameManager.gd")

	# Current player input
	if game_manager.current_state == GameManagerScript.GameState.PLAYING:
		var player = game_manager.get_current_player()

		if not player.is_empty() and not player.is_ai:
			if current_tank and current_tank.get_health() > 0:
				current_tank.handle_input(get_process_delta_time())

				# Weapon selection
				for i in range(1, 10):
					if Input.is_action_just_pressed("weapon_%d" % i):
						select_weapon(i - 1)

				# Shop toggle (TAB key)
				if Input.is_key_pressed(KEY_TAB):
					if shop and is_instance_valid(shop) and not shop.visible:
						shop.open_shop(game_manager.current_turn, game_manager)

	# Restart game
	if Input.is_action_just_pressed("ui_cancel"):
		if game_manager.current_state == GameManagerScript.GameState.GAME_OVER:
			get_tree().reload_current_scene()

func select_weapon(index: int) -> void:
	"""Select weapon by index"""
	var WeaponScript = load("res://scripts/Weapon.gd")
	var weapons = WeaponScript.get_all_weapons()
	if index >= 0 and index < weapons.size():
		current_weapon = weapons[index]
		print("Selected weapon: %s" % current_weapon.weapon_name)

func _input(event: InputEvent) -> void:
	"""Handle input events"""
	# Restart with R key
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		var GameManagerScript = load("res://scripts/GameManager.gd")
		if game_manager.current_state == GameManagerScript.GameState.GAME_OVER:
			print("\nRestarting game...")
			get_tree().reload_current_scene()

func _on_purchase_completed(item_type: String, item_id: String) -> void:
	"""Handle purchase completion"""
	print("Purchase completed: %s (%s)" % [item_id, item_type])

	# Update current weapon if weapon was purchased
	if item_type == "weapon":
		var WeaponScript = load("res://scripts/Weapon.gd")
		current_weapon = WeaponScript.get_weapon_by_id(item_id)
		print("Current weapon set to: %s" % current_weapon.weapon_name)

func _on_shop_closed() -> void:
	"""Handle shop close"""
	print("Shop closed, ready for turn")

func _on_terrain_theme_selected(theme: Terrain.TerrainTheme) -> void:
	"""Handle terrain theme selection (Phase 2.1)"""
	print("Terrain theme selected: %s" % theme)
	start_new_game(theme)

func _on_terrain_selection_cancelled() -> void:
	"""Handle terrain selection cancelled (Phase 2.1)"""
	print("Terrain selection cancelled, using default")
	start_new_game(Terrain.TerrainTheme.MOUNTAINS)
