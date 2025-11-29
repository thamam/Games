extends Control
class_name TerrainSelector

## Terrain Selection UI - Choose terrain theme before game start
## Phase 2.1 - Terrain Variety

signal theme_selected(theme: Terrain.TerrainTheme)
signal selection_cancelled()

## UI References
var panel: Panel
var title_label: Label
var theme_buttons: Array[Button] = []
var description_label: Label
var confirm_button: Button
var cancel_button: Button

## Selection State
var selected_theme: Terrain.TerrainTheme = Terrain.TerrainTheme.MOUNTAINS
var terrain_reference: Terrain  # Reference to terrain for getting theme info

func _ready() -> void:
	setup_ui()
	hide()  # Start hidden

func setup_ui() -> void:
	"""Create terrain selection UI"""
	# Set control to fill viewport
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL

	# Semi-transparent background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	add_child(bg)

	# Main panel
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(600, 500)
	panel.position = Vector2(340, 110)
	add_child(panel)

	# Title
	title_label = Label.new()
	title_label.text = "=== SELECT TERRAIN THEME ==="
	title_label.position = Vector2(20, 10)
	title_label.add_theme_font_size_override("font_size", 24)
	panel.add_child(title_label)

	# Theme buttons
	create_theme_buttons()

	# Description label
	description_label = Label.new()
	description_label.position = Vector2(20, 380)
	description_label.custom_minimum_size = Vector2(560, 60)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	description_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(description_label)

	# Confirm button
	confirm_button = Button.new()
	confirm_button.text = "Start Game"
	confirm_button.position = Vector2(200, 450)
	confirm_button.custom_minimum_size = Vector2(200, 40)
	confirm_button.pressed.connect(_on_confirm_pressed)
	panel.add_child(confirm_button)

	# Cancel button
	cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.position = Vector2(420, 450)
	cancel_button.custom_minimum_size = Vector2(160, 40)
	cancel_button.pressed.connect(_on_cancel_pressed)
	panel.add_child(cancel_button)

	# Select default theme
	update_description(Terrain.TerrainTheme.MOUNTAINS)

func create_theme_buttons() -> void:
	"""Create buttons for each terrain theme"""
	var themes = [
		Terrain.TerrainTheme.DESERT,
		Terrain.TerrainTheme.MOUNTAINS,
		Terrain.TerrainTheme.LUNAR,
		Terrain.TerrainTheme.ARCTIC,
		Terrain.TerrainTheme.VOLCANIC
	]

	var y_offset = 60
	var button_height = 60
	var spacing = 10

	for i in range(themes.size()):
		var terrain_theme = themes[i]
		var button = Button.new()
		button.custom_minimum_size = Vector2(560, button_height)
		button.position = Vector2(20, y_offset + i * (button_height + spacing))

		# Get theme info for button text
		var info = get_theme_info_static(terrain_theme)
		var button_text = "%s" % info.name
		if info.gravity_multiplier < 1.0:
			button_text += " (LOW GRAVITY)"
		button.text = button_text

		button.pressed.connect(_on_theme_button_pressed.bind(terrain_theme))
		panel.add_child(button)
		theme_buttons.append(button)

		# Highlight default selection
		if terrain_theme == Terrain.TerrainTheme.MOUNTAINS:
			button.modulate = Color(1.2, 1.2, 0.8)

func _on_theme_button_pressed(terrain_theme: Terrain.TerrainTheme) -> void:
	"""Handle theme button press"""
	selected_theme = terrain_theme
	update_description(terrain_theme)

	# Update button highlights
	for i in range(theme_buttons.size()):
		var btn = theme_buttons[i]
		if i == int(terrain_theme):
			btn.modulate = Color(1.2, 1.2, 0.8)  # Highlight selected
		else:
			btn.modulate = Color(1.0, 1.0, 1.0)  # Normal

func update_description(terrain_theme: Terrain.TerrainTheme) -> void:
	"""Update description label with theme details"""
	var info = get_theme_info_static(terrain_theme)

	var desc_text = "%s\n" % info.name
	desc_text += "%s\n" % info.description

	if info.gravity_multiplier < 1.0:
		desc_text += "⚠️ LOW GRAVITY: Projectiles travel farther!"
	elif info.roughness_modifier > 1.0:
		desc_text += "⚠️ Jagged terrain with dramatic elevation changes"
	elif info.roughness_modifier < 1.0:
		desc_text += "ℹ️ Smooth terrain with gentle slopes"

	description_label.text = desc_text

func _on_confirm_pressed() -> void:
	"""Confirm terrain selection and start game"""
	theme_selected.emit(selected_theme)
	hide()

func _on_cancel_pressed() -> void:
	"""Cancel terrain selection"""
	selection_cancelled.emit()
	hide()

func show_selector() -> void:
	"""Show the terrain selector"""
	show()
	grab_focus()

func get_theme_info_static(terrain_theme: Terrain.TerrainTheme) -> Dictionary:
	"""Get theme info without terrain instance (static version)"""
	match terrain_theme:
		Terrain.TerrainTheme.DESERT:
			return {
				"name": "Desert",
				"description": "Sandy dunes with smooth terrain",
				"terrain_color": Color(0.93, 0.79, 0.55),
				"sky_color": Color(0.53, 0.81, 0.92),
				"gravity_multiplier": 1.0,
				"roughness_modifier": 0.7
			}
		Terrain.TerrainTheme.MOUNTAINS:
			return {
				"name": "Mountains",
				"description": "Rocky peaks with varied elevation (DEFAULT)",
				"terrain_color": Color(0.5, 0.5, 0.5),
				"sky_color": Color(0.3, 0.5, 0.8),
				"gravity_multiplier": 1.0,
				"roughness_modifier": 1.0
			}
		Terrain.TerrainTheme.LUNAR:
			return {
				"name": "Lunar",
				"description": "Low gravity moon surface in deep space",
				"terrain_color": Color(0.4, 0.4, 0.4),
				"sky_color": Color(0.05, 0.05, 0.1),
				"gravity_multiplier": 0.5,
				"roughness_modifier": 0.8
			}
		Terrain.TerrainTheme.ARCTIC:
			return {
				"name": "Arctic",
				"description": "Frozen icy tundra with snow-covered peaks",
				"terrain_color": Color(0.9, 0.95, 1.0),
				"sky_color": Color(0.7, 0.85, 0.95),
				"gravity_multiplier": 1.0,
				"roughness_modifier": 0.9
			}
		Terrain.TerrainTheme.VOLCANIC:
			return {
				"name": "Volcanic",
				"description": "Molten lava and ash with jagged peaks",
				"terrain_color": Color(0.3, 0.1, 0.1),
				"sky_color": Color(0.4, 0.2, 0.1),
				"gravity_multiplier": 1.0,
				"roughness_modifier": 1.2
			}
	return {}
