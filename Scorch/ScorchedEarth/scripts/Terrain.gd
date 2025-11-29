extends Node2D
class_name Terrain

## Terrain System - Handles procedural generation, rendering, and destruction
## Uses pixel-based collision for fully destructible terrain

signal terrain_modified()

## Terrain Configuration
@export var terrain_width: int = 1280
@export var terrain_height: int = 720
@export var base_height: int = 500
@export var amplitude: float = 150.0  # Vertical variation amplitude
@export var octaves: int = 4  # Number of noise layers for detail
@export var terrain_color: Color = Color(0.6, 0.4, 0.2)  # Brown
@export var sky_color: Color = Color(0.3, 0.5, 0.8)  # Blue

## Noise generator for fractal terrain
var noise: FastNoiseLite

## Theme Configuration
enum TerrainTheme {
	DESERT,
	MOUNTAINS,
	LUNAR,
	ARCTIC,
	VOLCANIC
}

var current_theme: TerrainTheme = TerrainTheme.MOUNTAINS
var theme_gravity_multiplier: float = 1.0  # Modifier for physics gravity

## Terrain Data
var terrain_image: Image
var terrain_texture: ImageTexture
var terrain_sprite: Sprite2D
var collision_body: StaticBody2D  # Track the physics body

## Height map for quick access
var height_map: PackedInt32Array

func _ready() -> void:
	generate_terrain()

func generate_terrain(seed_value: int = -1) -> void:
	"""Generate procedural terrain using fractal Perlin noise"""
	# Initialize noise generator
	if not noise:
		noise = FastNoiseLite.new()

	if seed_value > 0:
		noise.seed = seed_value
	else:
		noise.seed = randi()

	# Configure noise for terrain generation
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM  # Fractional Brownian Motion
	noise.fractal_octaves = octaves  # Number of detail layers
	noise.fractal_lacunarity = 2.0  # Frequency multiplier per octave (doubles each octave)
	noise.fractal_gain = 0.5  # Amplitude multiplier per octave (halves each octave)
	noise.frequency = 0.003  # Base frequency (lower = larger features)

	# Create terrain image
	terrain_image = Image.create(terrain_width, terrain_height, false, Image.FORMAT_RGBA8)

	# Fill with sky color first
	terrain_image.fill(sky_color)

	# Generate height map using fractal noise
	height_map = PackedInt32Array()
	height_map.resize(terrain_width)

	# Generate terrain using fractal noise: H(x) = Σ A_i * noise(Frequency_i * x)
	var min_height = INF
	var max_height = -INF

	for x in range(terrain_width):
		# Get noise value (-1 to 1)
		var noise_value = noise.get_noise_1d(x)

		# Convert to height using amplitude
		var height = base_height + (noise_value * amplitude)

		# Track min/max for normalization
		min_height = min(min_height, height)
		max_height = max(max_height, height)

		height_map[x] = int(height)

	# Normalize heights to use full terrain range effectively
	var height_range = max_height - min_height
	for x in range(terrain_width):
		var normalized = (height_map[x] - min_height) / height_range
		# Map to terrain range with some margin
		height_map[x] = int(100 + normalized * (terrain_height - 200))

	# Draw terrain based on height map
	for x in range(terrain_width):
		var height = height_map[x]
		for y in range(height, terrain_height):
			terrain_image.set_pixel(x, y, terrain_color)

	# Create texture from image
	terrain_texture = ImageTexture.create_from_image(terrain_image)

	# Create or update sprite
	if not terrain_sprite:
		terrain_sprite = Sprite2D.new()
		terrain_sprite.centered = false
		terrain_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(terrain_sprite)

	terrain_sprite.texture = terrain_texture

	# Create collision for terrain
	setup_collision()

	print("Terrain generated: %dx%d (Fractal Noise)" % [terrain_width, terrain_height])


func setup_collision() -> void:
	"""Create collision shape for terrain using segments to avoid convex decomposition"""
	# Remove old collision body if exists
	if collision_body:
		collision_body.queue_free()
		collision_body = null

	# Create StaticBody2D for terrain collision
	collision_body = StaticBody2D.new()
	add_child(collision_body)

	# Use segment-based collision instead of polygon to avoid "Convex decomposing failed!"
	# Create collision segments connecting surface points
	var segment_width = 8  # Width of each segment (pixels)
	var segment_count = 0

	for x in range(0, terrain_width - segment_width, segment_width):
		# Get heights at segment start and end
		var h1 = height_map[x]
		var h2 = height_map[min(x + segment_width, terrain_width - 1)]

		# Create a small rectangular collision shape for this segment
		var segment_shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()

		# Calculate segment dimensions and position
		var segment_height = 20.0  # Thickness below surface
		var avg_height = (h1 + h2) / 2.0
		var segment_center = Vector2(x + segment_width / 2.0, avg_height + segment_height / 2.0)

		rect_shape.size = Vector2(segment_width, segment_height)
		segment_shape.position = segment_center
		segment_shape.shape = rect_shape

		collision_body.add_child(segment_shape)
		segment_count += 1

	print("Collision created with %d segments" % segment_count)

func destroy_terrain(pos: Vector2, radius: float, add_dirt: bool = false) -> void:
	"""Destroy (or add) terrain at position with given radius"""
	var center_x = int(pos.x)
	var center_y = int(pos.y)

	# Calculate bounds
	var min_x = max(0, center_x - int(radius))
	var max_x = min(terrain_width - 1, center_x + int(radius))
	var min_y = max(0, center_y - int(radius))
	var max_y = min(terrain_height - 1, center_y + int(radius))

	var radius_squared = radius * radius
	var modified = false

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var dx = x - center_x
			var dy = y - center_y
			var dist_squared = dx * dx + dy * dy

			if dist_squared <= radius_squared:
				if add_dirt:
					# Add terrain
					terrain_image.set_pixel(x, y, terrain_color)
				else:
					# Remove terrain
					terrain_image.set_pixel(x, y, sky_color)
				modified = true

	if modified:
		# Update height map only for affected region
		update_height_map(min_x, max_x)

		# Update texture
		terrain_texture.update(terrain_image)

		# Update collision
		setup_collision()

		terrain_modified.emit()

func update_height_map(start_x: int = 0, end_x: int = -1) -> void:
	"""Update height map based on current terrain image, optionally for a specific range"""
	if end_x == -1:
		end_x = terrain_width - 1

	# Clamp to valid range
	start_x = clamp(start_x, 0, terrain_width - 1)
	end_x = clamp(end_x, 0, terrain_width - 1)

	for x in range(start_x, end_x + 1):
		var height = 0
		# Find first solid pixel from top
		for y in range(terrain_height):
			var pixel = terrain_image.get_pixel(x, y)
			if pixel.a > 0.5 and pixel.is_equal_approx(terrain_color):
				height = y
				break
		height_map[x] = height if height > 0 else terrain_height

func get_height_at(x: float) -> float:
	"""Get terrain height at x position"""
	var ix = int(x)
	if ix >= 0 and ix < terrain_width:
		return height_map[ix]
	return terrain_height

func is_solid_at(pos: Vector2) -> bool:
	"""Check if position is solid terrain"""
	var x = int(pos.x)
	var y = int(pos.y)

	if x < 0 or x >= terrain_width or y < 0 or y >= terrain_height:
		return false

	var pixel = terrain_image.get_pixel(x, y)
	# Check if pixel is terrain color (not sky)
	return pixel.is_equal_approx(terrain_color)

func get_surface_normal(x: float) -> Vector2:
	"""Get surface normal at x position for physics"""
	var ix = int(x)
	if ix <= 0 or ix >= terrain_width - 1:
		return Vector2.UP

	var left_height = height_map[ix - 1]
	var right_height = height_map[ix + 1]

	var tangent = Vector2(2.0, right_height - left_height).normalized()
	var normal = Vector2(-tangent.y, tangent.x)

	return normal

func find_spawn_position(index: int, total: int) -> Vector2:
	"""Find suitable spawn position for tank"""
	# Distribute tanks evenly across terrain
	var spacing = int(terrain_width / (total + 1))
	var x = spacing * (index + 1)

	# Adjust x to avoid edges
	x = clamp(x, 100, terrain_width - 100)

	# Get height at this x position
	var y = get_height_at(x) - 20  # Spawn slightly above terrain

	return Vector2(x, y)

func apply_gravity_to_loose_terrain() -> void:
	"""Make unsupported terrain fall (not implemented in this version)"""
	# This would be a complex feature for later
	pass

## Terrain type presets

func get_theme_info(theme: TerrainTheme) -> Dictionary:
	"""Get information about a terrain theme"""
	match theme:
		TerrainTheme.DESERT:
			return {
				"name": "Desert",
				"description": "Sandy dunes with smooth terrain",
				"terrain_color": Color(0.93, 0.79, 0.55),
				"sky_color": Color(0.53, 0.81, 0.92),
				"gravity_multiplier": 1.0,
				"roughness_modifier": 0.7  # Smoother terrain
			}
		TerrainTheme.MOUNTAINS:
			return {
				"name": "Mountains",
				"description": "Rocky peaks with varied elevation",
				"terrain_color": Color(0.5, 0.5, 0.5),
				"sky_color": Color(0.3, 0.5, 0.8),
				"gravity_multiplier": 1.0,
				"roughness_modifier": 1.0  # Normal terrain
			}
		TerrainTheme.LUNAR:
			return {
				"name": "Lunar",
				"description": "Low gravity moon surface",
				"terrain_color": Color(0.4, 0.4, 0.4),
				"sky_color": Color(0.05, 0.05, 0.1),
				"gravity_multiplier": 0.5,  # Low gravity!
				"roughness_modifier": 0.8
			}
		TerrainTheme.ARCTIC:
			return {
				"name": "Arctic",
				"description": "Frozen icy tundra",
				"terrain_color": Color(0.9, 0.95, 1.0),
				"sky_color": Color(0.7, 0.85, 0.95),
				"gravity_multiplier": 1.0,
				"roughness_modifier": 0.9
			}
		TerrainTheme.VOLCANIC:
			return {
				"name": "Volcanic",
				"description": "Molten lava and ash",
				"terrain_color": Color(0.3, 0.1, 0.1),
				"sky_color": Color(0.4, 0.2, 0.1),
				"gravity_multiplier": 1.0,
				"roughness_modifier": 1.2  # More jagged
			}
	return {}

func set_theme(theme: TerrainTheme) -> void:
	"""Apply a terrain theme with all its properties"""
	current_theme = theme
	var info = get_theme_info(theme)

	terrain_color = info.terrain_color
	sky_color = info.sky_color
	theme_gravity_multiplier = info.gravity_multiplier

	# Adjust amplitude based on theme (renamed from roughness_modifier)
	var base_amplitude = 150.0
	amplitude = base_amplitude * info.roughness_modifier

	# Apply gravity to physics system
	var base_gravity = 980.0
	var new_gravity = base_gravity * theme_gravity_multiplier
	ProjectSettings.set_setting("physics/2d/default_gravity", new_gravity)

	generate_terrain()

	print("Theme applied: %s (Gravity: %.0f)" % [info.name, new_gravity])

func set_desert_theme() -> void:
	"""Set desert terrain theme"""
	set_theme(TerrainTheme.DESERT)

func set_mountain_theme() -> void:
	"""Set mountain terrain theme"""
	set_theme(TerrainTheme.MOUNTAINS)

func set_lunar_theme() -> void:
	"""Set lunar terrain theme (LOW GRAVITY)"""
	set_theme(TerrainTheme.LUNAR)

func set_volcanic_theme() -> void:
	"""Set volcanic terrain theme"""
	set_theme(TerrainTheme.VOLCANIC)

func set_arctic_theme() -> void:
	"""Set arctic terrain theme"""
	set_theme(TerrainTheme.ARCTIC)
