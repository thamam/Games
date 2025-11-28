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
			"fuel": 0
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

	# Set wind for this round
	current_wind = Vector2(randf_range(-50, 50), 0)
	print("Wind: %.1f" % current_wind.x)

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
	await get_tree().create_timer(0.5).timeout
	start_playing()

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
	"""Handle AI player's turn"""
	await get_tree().create_timer(1.0).timeout  # AI "thinking" time

	var current_player = players[current_player_index]
	var current_tank = tanks[current_player_index]

	# Simple AI: Pick random target and shoot
	var target_index = get_random_alive_player()
	if target_index >= 0:
		var target_tank = tanks[target_index]

		# Calculate approximate angle and power
		var angle = calculate_angle_to_target(current_tank, target_tank)
		var power = randf_range(0.5, 1.0)

		# Add some randomness based on AI level
		var difficulty = current_player.ai_level
		var accuracy = 0.3 + (difficulty * 0.3)  # 0=30%, 1=60%, 2=90% accuracy
		angle += randf_range(-30.0, 30.0) * (1.0 - accuracy)

		# Set tank controls and fire (Main scene will handle projectile creation)
		current_tank.set_cannon_angle(angle)
		current_tank.set_fire_power(power)
		current_player.shots_fired += 1
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
