extends Control
class_name Shop

## Shop UI - Weapon and item purchasing system
## GDD Reference: Section 2.2 (Economy System), 2.4 (Defensive & Utility Items)

signal purchase_completed(item_type: String, item_id: String)
signal shop_closed()

## References
var game_manager  # GameManager (untyped to avoid circular dependency)
var current_player_index: int = 0

## UI Components
var panel: Panel
var title_label: Label
var money_label: Label
var weapons_container: VBoxContainer
var items_container: VBoxContainer
var close_button: Button
var item_buttons: Array[Button] = []

## Shop categories
enum Category { WEAPONS, DEFENSIVE, UTILITY }

func _ready() -> void:
	setup_ui()
	hide()  # Start hidden

func setup_ui() -> void:
	"""Create shop UI layout"""
	# Set control to fill viewport
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL  # Enable focus for this control

	# Semi-transparent background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	add_child(bg)

	# Main panel
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(800, 600)
	panel.position = Vector2(240, 60)
	add_child(panel)

	# Title
	title_label = Label.new()
	title_label.text = "=== SHOP ==="
	title_label.position = Vector2(20, 10)
	title_label.add_theme_font_size_override("font_size", 24)
	panel.add_child(title_label)

	# Money display
	money_label = Label.new()
	money_label.position = Vector2(20, 50)
	money_label.add_theme_font_size_override("font_size", 18)
	panel.add_child(money_label)

	# Weapons section
	var weapons_label = Label.new()
	weapons_label.text = "=== WEAPONS ==="
	weapons_label.position = Vector2(20, 90)
	weapons_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(weapons_label)

	weapons_container = VBoxContainer.new()
	weapons_container.position = Vector2(20, 120)
	weapons_container.custom_minimum_size = Vector2(760, 300)
	panel.add_child(weapons_container)

	# Defensive items section
	var items_label = Label.new()
	items_label.text = "=== DEFENSIVE & UTILITY ==="
	items_label.position = Vector2(20, 430)
	items_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(items_label)

	items_container = VBoxContainer.new()
	items_container.position = Vector2(20, 460)
	items_container.custom_minimum_size = Vector2(760, 100)
	panel.add_child(items_container)

	# Close button
	close_button = Button.new()
	close_button.text = "[SPACE] Skip Shopping | [ESC] Close"
	close_button.position = Vector2(250, 570)
	close_button.custom_minimum_size = Vector2(300, 30)
	close_button.pressed.connect(_on_close_pressed)
	panel.add_child(close_button)

func open_shop(player_index: int, mgr) -> void:
	"""Open shop for specific player"""
	current_player_index = player_index
	game_manager = mgr

	if not game_manager:
		push_error("Shop: No game manager provided")
		return

	var player = game_manager.get_player_by_index(player_index)
	if player.is_empty():
		push_error("Shop: Invalid player index")
		return

	# Update UI
	title_label.text = "=== SHOP - %s ===" % player.name
	money_label.text = "Money: $%d" % player.money

	# Populate shop items
	populate_weapons()
	populate_items()

	show()
	grab_focus()

func populate_weapons() -> void:
	"""Populate weapons list"""
	# Clear existing
	for child in weapons_container.get_children():
		child.queue_free()
	item_buttons.clear()

	var WeaponScript = load("res://scripts/Weapon.gd")
	var weapons = WeaponScript.get_all_weapons()

	for weapon in weapons:
		var button = create_shop_button(
			weapon.weapon_name,
			weapon.description,
			weapon.cost,
			weapon.damage,
			weapon.explosion_radius,
			"weapon",
			weapon.weapon_id
		)
		weapons_container.add_child(button)
		item_buttons.append(button)

func populate_items() -> void:
	"""Populate defensive and utility items"""
	# Clear existing
	for child in items_container.get_children():
		child.queue_free()

	# Define items (GDD Section 2.4)
	var items = [
		{"name": "Heavy Shield", "desc": "Absorbs 50 damage", "cost": 1000, "type": "shield", "id": "heavy_shield", "value": 50},
		{"name": "Medium Shield", "desc": "Absorbs 25 damage", "cost": 500, "type": "shield", "id": "medium_shield", "value": 25},
		{"name": "Light Shield", "desc": "Absorbs 10 damage", "cost": 250, "type": "shield", "id": "light_shield", "value": 10},
		{"name": "Shield Battery", "desc": "Recharge shields", "cost": 750, "type": "battery", "id": "shield_battery", "value": 0},
		{"name": "Parachute", "desc": "Prevents fall damage (1 use)", "cost": 500, "type": "parachute", "id": "parachute", "value": 1},
		{"name": "Fuel Tank", "desc": "Movement fuel", "cost": 400, "type": "fuel", "id": "fuel_tank", "value": 100},
	]

	for item in items:
		var button = create_item_button(
			item.name,
			item.desc,
			item.cost,
			item.type,
			item.id,
			item.value
		)
		items_container.add_child(button)
		item_buttons.append(button)

func create_shop_button(weapon_name: String, desc: String, cost: int, damage: int, radius: float, item_type: String, item_id: String) -> Button:
	"""Create a weapon purchase button"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(750, 30)
	button.text = "[%-20s] $%-5d  DMG:%-4d  RAD:%-4.0f  %s" % [weapon_name, cost, damage, radius, desc]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Store data
	button.set_meta("cost", cost)
	button.set_meta("item_type", item_type)
	button.set_meta("item_id", item_id)

	button.pressed.connect(_on_purchase_button_pressed.bind(button))

	return button

func create_item_button(item_name: String, desc: String, cost: int, item_type: String, item_id: String, value: int) -> Button:
	"""Create a defensive/utility item purchase button"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(750, 25)
	button.text = "[%-20s] $%-5d  %s" % [item_name, cost, desc]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Store data
	button.set_meta("cost", cost)
	button.set_meta("item_type", item_type)
	button.set_meta("item_id", item_id)
	button.set_meta("value", value)

	button.pressed.connect(_on_purchase_button_pressed.bind(button))

	return button

func _on_purchase_button_pressed(button: Button) -> void:
	"""Handle purchase button click"""
	if not game_manager:
		return

	var cost = button.get_meta("cost") as int
	var item_type = button.get_meta("item_type") as String
	var item_id = button.get_meta("item_id") as String

	var player = game_manager.get_player_by_index(current_player_index)
	if player.is_empty():
		return

	# Check if player has enough money
	if player.money < cost:
		print("Insufficient funds! Need $%d, have $%d" % [cost, player.money])
		# TODO: Show error feedback
		return

	# Process purchase
	player.money -= cost
	print("%s purchased %s for $%d (balance: $%d)" % [player.name, item_id, cost, player.money])

	# Apply purchase effect
	match item_type:
		"weapon":
			# Add to inventory
			if not player.inventory.has(item_id):
				player.inventory[item_id] = 0
			player.inventory[item_id] += 1
			print("  Inventory: %s x%d" % [item_id, player.inventory[item_id]])

		"shield":
			var value = button.get_meta("value") as int
			player.shields += value
			print("  Shields: %d" % player.shields)

		"battery":
			# Recharge shields to max (TODO: define max shields)
			player.shields = min(player.shields + 50, 100)
			print("  Shields recharged to: %d" % player.shields)

		"parachute":
			var value = button.get_meta("value") as int
			player.parachutes += value
			print("  Parachutes: %d" % player.parachutes)

		"fuel":
			var value = button.get_meta("value") as int
			player.fuel += value
			print("  Fuel: %d" % player.fuel)

	# Update money display
	money_label.text = "Money: $%d" % player.money

	# Emit signal
	purchase_completed.emit(item_type, item_id)

func _on_close_pressed() -> void:
	"""Close shop"""
	print("Shop closed for %s" % game_manager.get_player_by_index(current_player_index).name)
	shop_closed.emit()
	hide()

func _input(event: InputEvent) -> void:
	"""Handle keyboard shortcuts"""
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):  # ESC
		_on_close_pressed()
		accept_event()
	elif event.is_action_pressed("fire"):  # SPACE - skip shopping
		_on_close_pressed()
		accept_event()
