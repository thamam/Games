extends Node
class_name GameManager

## Game Manager - Orchestrates the entire game flow
## Manages turns, players, game state, and win conditions

signal turn_started(player_index: int)
signal turn_ended(player_index: int)
signal game_over(winner_index: int)
signal round_started(round_number: int)
signal round_ended()

enum GameState {
	MENU,
	SETUP,
	SHOP,
	PLAYING,
	GAME_OVER
}

## Game Configuration
@export var num_players: int = 2
@export var starting_money: int = 10000
@export var interest_rate: float = 0.1  # 10% interest per round
@export var kill_bonus: int = 500
@export var max_turn_time: float = 60.0  # seconds

## Game State
var current_state: GameState = GameState.MENU
var current_player_index: int = 0
var current_round: int = 1
var turn_timer: float = 0.0
var current_wind: Vector2 = Vector2.ZERO  # Consistent wind per round
var wind_strength: String = "Calm"  # Wind description (Phase 2.2)

## Player Data
var players: Array[Dictionary] = []
var active_players: Array[int] = []  # Indices of alive players

## References
var terrain  # Terrain reference (untyped to avoid circular dependency)
var tanks: Array = []  # Array of Tank objects
var current_projectile = null  # Current Projectile

func _ready() -> void:
	initialize_game()

func initialize_game() -> void:
	"""Initialize game with default settings"""
	print("Scorched Earth - Game Initialized")
	# Will be called from Main scene

func setup_new_game(player_count: int, ai_players: Array[Dictionary] = []) -> void:
	"""Setup a new game with specified players"""
	num_players = player_count
	current_round = 1
	current_player_index = 0
	players.clear()
	tanks.clear()
	active_players.clear()

	# Create player data
	for i in range(num_players):
		var player_data = {
			"index": i,
			"name": "Player %d" % (i + 1),
			"money": starting_money,
			"health": 100,
			"is_ai": i < ai_players.size(),
			"ai_level": ai_players[i].get("level", 0) if i < ai_players.size() else 0,
			"kills": 0,
			"damage_dealt": 0,
			"shots_fired": 0,
			"color": get_player_color(i),
			"inventory": {},
			"shields": 0,
			"parachutes": 0,
			"fuel": 100  # Starting fuel for testing (normally purchased from shop)
		}
		players.append(player_data)
		active_players.append(i)

	current_state = GameState.SETUP
	print("Game setup complete with %d players" % num_players)

func get_player_color(index: int) -> Color:
	"""Get distinct color for each player"""
	var colors = [
		Color.RED,
		Color.BLUE,
		Color.GREEN,
		Color.YELLOW,
		Color.MAGENTA,
		Color.CYAN,
		Color.ORANGE,
		Color.PURPLE,
		Color.LIME,
		Color.PINK
	]
	return colors[index % colors.size()]

func start_round() -> void:
	"""Start a new round"""
	print("=== Round %d Started ===" % current_round)

	# Set wind for this round (Phase 2.2: Wind Variety)
	generate_wind()
	var wind_dir = "→" if current_wind.x > 0 else "←"
	print("Wind: %s %s (%.1f)" % [wind_strength, wind_dir, abs(current_wind.x)])

	# Apply interest to all players
	for player in players:
		var interest = int(player.money * interest_rate)
		player.money += interest
		if interest > 0:
			print("%s earned $%d interest" % [player.name, interest])

	current_state = GameState.SHOP
	round_started.emit(current_round)

	# After shop phase, start playing
	# For now, skip shop and go straight to playing
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout
		start_playing()
	else:
		return  # Node not in tree, abort round start

func generate_wind() -> void:
	"""Generate wind with varying strength and direction (Phase 2.2)"""
	# Wind categories based on Scorched Earth original design
	var wind_categories = [
		{"name": "Calm", "min": 0.0, "max": 10.0, "weight": 30},
		{"name": "Breeze", "min": 10.0, "max": 25.0, "weight": 40},
		{"name": "Strong", "min": 25.0, "max": 50.0, "weight": 20},
		{"name": "Storm", "min": 50.0, "max": 80.0, "weight": 10}
	]

	# Weighted random selection of wind category
	var total_weight = 0
	for category in wind_categories:
		total_weight += category.weight

	var random_weight = randf() * total_weight
	var accumulated_weight = 0.0
	var selected_category = wind_categories[0]

	for category in wind_categories:
		accumulated_weight += category.weight
		if random_weight <= accumulated_weight:
			selected_category = category
			break

	# Generate wind speed within category range
	var wind_speed = randf_range(selected_category.min, selected_category.max)

	# Randomly choose direction (50% left, 50% right)
	var direction = 1.0 if randf() > 0.5 else -1.0

	# Set wind state
	current_wind = Vector2(wind_speed * direction, 0.0)
	wind_strength = selected_category.name

func start_playing() -> void:
	"""Begin the playing phase"""
	current_state = GameState.PLAYING
	current_player_index = 0
	start_turn()

func start_turn() -> void:
	"""Start the current player's turn"""
	# Skip dead players
	while current_player_index in range(num_players) and \
		  players[current_player_index].health <= 0:
		current_player_index = (current_player_index + 1) % num_players

	if check_game_over():
		return

	var current_player = players[current_player_index]
	print("\n--- %s's Turn ---" % current_player.name)

	turn_timer = max_turn_time
	turn_started.emit(current_player_index)

	# If AI player, handle AI turn
	if current_player.is_ai:
		handle_ai_turn()

func handle_ai_turn() -> void:
	"""Handle AI player's turn with difficulty-based intelligence"""
	var current_player = players[current_player_index]
	var current_tank = tanks[current_player_index]

	# AI shopping phase (if has money and needs weapons/items)
	ai_shopping_phase(current_player)

	# AI "thinking" time (varies by difficulty)
	var think_time = 1.5 - (current_player.ai_level * 0.3)  # Harder AI thinks faster
	if is_inside_tree():
		await get_tree().create_timer(think_time).timeout
	else:
		return  # Node not in tree, abort AI turn

	# Select target
	var target_index = ai_select_target(current_player)
	if target_index < 0:
		# No valid targets - skip turn
		return

	var target_tank = tanks[target_index]

	# Select weapon
	var weapon_choice = ai_select_weapon(current_player, target_tank)

	# Calculate shot parameters
	var shot_params = ai_calculate_shot(current_player, current_tank, target_tank)

	if shot_params:
		# Apply difficulty-based accuracy modifiers
		shot_params = ai_apply_accuracy_modifier(current_player, shot_params)

		# Execute shot
		current_tank.set_cannon_angle(shot_params.angle)
		current_tank.set_fire_power(shot_params.power)
		current_player.shots_fired += 1
		current_tank.fire(weapon_choice)
	else:
		# Fallback: random shot
		current_tank.set_cannon_angle(randf_range(30, 150))
		current_tank.set_fire_power(randf_range(0.5, 1.0))
		current_tank.fire("missile")

func calculate_angle_to_target(from_tank, to_tank) -> float:  # Tank parameters (untyped to avoid circular dependency)
	"""Calculate approximate angle to hit target (simplified)"""
	var dx = to_tank.global_position.x - from_tank.global_position.x
	var dy = to_tank.global_position.y - from_tank.global_position.y

	# Simple ballistic calculation (not perfect, but good enough for AI)
	var angle = rad_to_deg(atan2(-dy, dx))

	# Clamp to valid range (0-180 degrees for tank cannon)
	angle = clamp(angle, 0.0, 180.0)

	return angle

func get_random_alive_player() -> int:
	"""Get random player index that is not current player and is alive"""
	var valid_targets = []
	for i in range(num_players):
		if i != current_player_index and players[i].health > 0:
			valid_targets.append(i)

	if valid_targets.is_empty():
		return -1

	return valid_targets[randi() % valid_targets.size()]

## AI System Functions

func ai_shopping_phase(player: Dictionary) -> void:
	"""AI purchases weapons and items strategically"""
	# Only shop if has significant money
	if player.money < 500:
		return

	# Defensive purchases (shields if low health)
	if player.health < 50 and player.money >= 500:
		player.shields += 25
		player.money -= 500
		print("%s (AI) purchased Medium Shield" % player.name)

	# Weapon purchases based on money available
	if player.money >= 3000 and randf() < 0.3:
		# Buy expensive weapon (MIRV or Heat Seeker)
		var weapon_id = "mirv" if randf() < 0.5 else "heat_seeker"
		if not player.inventory.has(weapon_id):
			player.inventory[weapon_id] = 0
		player.inventory[weapon_id] += 1
		player.money -= 3000
		print("%s (AI) purchased %s" % [player.name, weapon_id])
	elif player.money >= 1500 and randf() < 0.4:
		# Buy mid-tier weapon
		if not player.inventory.has("heavy_missile"):
			player.inventory["heavy_missile"] = 0
		player.inventory["heavy_missile"] += 1
		player.money -= 1500
		print("%s (AI) purchased heavy_missile" % player.name)

func ai_select_target(player: Dictionary) -> int:
	"""Select target based on AI difficulty and strategy"""
	var valid_targets = []
	for i in range(num_players):
		if i != current_player_index and players[i].health > 0:
			valid_targets.append(i)

	if valid_targets.is_empty():
		return -1

	match player.ai_level:
		0:  # Lobber - Random target
			return valid_targets[randi() % valid_targets.size()]
		1, 2:  # Poolshark/Spoiler - Target weakest or nearest
			var best_target = valid_targets[0]
			var best_score = INF

			for target_idx in valid_targets:
				# Score = health (prefer weak) + distance (prefer close)
				var distance = tanks[current_player_index].global_position.distance_to(
					tanks[target_idx].global_position
				)
				var score = players[target_idx].health * 2 + distance * 0.1

				if score < best_score:
					best_score = score
					best_target = target_idx

			return best_target

	return valid_targets[0]

func ai_select_weapon(player: Dictionary, _target_tank) -> String:
	"""Select appropriate weapon from inventory"""
	# If has special weapons in inventory, use strategically
	if player.inventory.has("heat_seeker") and player.inventory["heat_seeker"] > 0:
		player.inventory["heat_seeker"] -= 1
		return "heat_seeker"

	if player.inventory.has("mirv") and player.inventory["mirv"] > 0:
		player.inventory["mirv"] -= 1
		return "mirv"

	if player.inventory.has("heavy_missile") and player.inventory["heavy_missile"] > 0:
		player.inventory["heavy_missile"] -= 1
		return "heavy_missile"

	# Default to basic missile
	return "missile"

func ai_calculate_shot(player: Dictionary, from_tank, to_tank) -> Dictionary:
	"""Calculate ballistic trajectory using physics"""
	var start_pos = from_tank.global_position
	var target_pos = to_tank.global_position

	var _dx = target_pos.x - start_pos.x
	var _dy = target_pos.y - start_pos.y

	# Get gravity and wind
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	var wind_x = current_wind.x

	# Try different angles to find best shot
	var best_angle = 45.0
	var best_power = 0.7
	var best_error = INF

	# Difficulty determines how many attempts AI makes
	var attempts = 5 + (player.ai_level * 10)  # 5, 15, 25 attempts

	for i in range(attempts):
		var test_angle = randf_range(20, 160)
		var test_power = randf_range(0.3, 1.0)

		# Calculate where shot would land
		var predicted_error = calculate_shot_error(
			start_pos, test_angle, test_power, target_pos, gravity, wind_x
		)

		if predicted_error < best_error:
			best_error = predicted_error
			best_angle = test_angle
			best_power = test_power

	return {"angle": best_angle, "power": best_power, "error": best_error}

func calculate_shot_error(start_pos: Vector2, angle: float, power: float,
						 target: Vector2, gravity: float, wind: float) -> float:
	"""Simple ballistic prediction to estimate shot accuracy"""
	# Initial velocity
	var speed = power * 500.0  # Max velocity
	var rad_angle = deg_to_rad(angle)
	var vx = cos(rad_angle) * speed
	var vy = -sin(rad_angle) * speed

	# Simulate trajectory for limited time
	var pos = start_pos
	var vel = Vector2(vx, vy)
	var time_step = 0.1
	var max_time = 5.0

	for t in range(int(max_time / time_step)):
		# Apply physics
		vel.y += gravity * time_step
		vel.x += wind * time_step * 0.5  # Wind effect

		pos += vel * time_step

		# Check if close to target height
		if pos.y >= target.y:
			# Calculate horizontal error
			return abs(pos.x - target.x)

	# Shot goes too high or too far
	return 9999.0

func ai_apply_accuracy_modifier(player: Dictionary, shot_params: Dictionary) -> Dictionary:
	"""Apply difficulty-based aiming error"""
	match player.ai_level:
		0:  # Lobber - Very inaccurate (30-50% accuracy)
			shot_params.angle += randf_range(-40, 40)
			shot_params.power += randf_range(-0.3, 0.3)
		1:  # Poolshark - Moderate accuracy (60-80%)
			shot_params.angle += randf_range(-15, 15)
			shot_params.power += randf_range(-0.15, 0.15)
		2:  # Spoiler - High accuracy (90-95%)
			shot_params.angle += randf_range(-5, 5)
			shot_params.power += randf_range(-0.05, 0.05)

	# Clamp to valid ranges
	shot_params.angle = clamp(shot_params.angle, 0, 180)
	shot_params.power = clamp(shot_params.power, 0.1, 1.0)

	return shot_params

func end_turn() -> void:
	"""End the current player's turn"""
	turn_ended.emit(current_player_index)

	# Move to next player
	current_player_index = (current_player_index + 1) % num_players

	# If we've cycled back to player 0, round is over
	if current_player_index == 0:
		end_round()
	else:
		start_turn()

func end_round() -> void:
	"""End the current round"""
	print("=== Round %d Ended ===" % current_round)
	round_ended.emit()

	if not check_game_over():
		current_round += 1
		start_round()

func apply_damage(tank_index: int, damage: int, attacker_index: int = -1) -> void:
	"""Apply damage to a tank"""
	if tank_index < 0 or tank_index >= players.size():
		return

	var player = players[tank_index]

	# Apply shields
	if player.shields > 0:
		var shield_absorbed = min(damage, player.shields)
		player.shields -= shield_absorbed
		damage -= shield_absorbed
		print("%s's shield absorbed %d damage" % [player.name, shield_absorbed])

	# Apply remaining damage
	player.health -= damage
	player.health = max(0, player.health)

	print("%s takes %d damage (Health: %d)" % [player.name, damage, player.health])

	# Track attacker stats
	if attacker_index >= 0 and attacker_index < players.size():
		players[attacker_index].damage_dealt += damage

	# Check if killed
	if player.health <= 0:
		handle_player_death(tank_index, attacker_index)

func handle_player_death(tank_index: int, killer_index: int = -1) -> void:
	"""Handle when a player is eliminated"""
	var player = players[tank_index]
	print("%s has been eliminated!" % player.name)

	# Remove from active players
	active_players.erase(tank_index)

	# Award kill bonus
	if killer_index >= 0 and killer_index < players.size():
		players[killer_index].kills += 1
		players[killer_index].money += kill_bonus
		print("%s gets $%d kill bonus" % [players[killer_index].name, kill_bonus])

	# Destroy tank visual
	if tank_index < tanks.size() and tanks[tank_index]:
		tanks[tank_index].destroy()

func check_game_over() -> bool:
	"""Check if game is over (only one player remaining)"""
	var alive_count = 0
	var winner_index = -1

	for i in range(num_players):
		if players[i].health > 0:
			alive_count += 1
			winner_index = i

	if alive_count <= 1:
		end_game(winner_index)
		return true

	return false

func end_game(winner_index: int) -> void:
	"""End the game and declare winner"""
	current_state = GameState.GAME_OVER

	if winner_index >= 0:
		var winner = players[winner_index]
		print("\n🎉 GAME OVER - %s WINS! 🎉" % winner.name)
		print("Stats:")
		print("  Kills: %d" % winner.kills)
		print("  Damage Dealt: %d" % winner.damage_dealt)
		print("  Shots Fired: %d" % winner.shots_fired)
		print("  Money: $%d" % winner.money)
	else:
		print("\n GAME OVER - Draw!")

	game_over.emit(winner_index)

func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		# Update turn timer
		turn_timer -= delta
		if turn_timer <= 0:
			print("Turn time expired!")
			end_turn()

## Utility Functions

func get_current_player() -> Dictionary:
	"""Get current player data"""
	if current_player_index >= 0 and current_player_index < players.size():
		return players[current_player_index]
	return {}

func get_player_by_index(index: int) -> Dictionary:
	"""Get player data by index"""
	if index >= 0 and index < players.size():
		return players[index]
	return {}

func get_wind() -> Vector2:
	"""Get current wind vector"""
	return current_wind
