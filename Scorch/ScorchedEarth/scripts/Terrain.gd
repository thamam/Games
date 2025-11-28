extends Node2D
class_name Terrain

## Terrain System - Handles procedural generation, rendering, and destruction
## Uses pixel-based collision for fully destructible terrain

signal terrain_modified()

## Terrain Configuration
@export var terrain_width: int = 1280
@export var terrain_height: int = 720
@export var base_height: int = 500
@export var roughness: float = 50.0
@export var terrain_color: Color = Color(0.6, 0.4, 0.2)  # Brown
@export var sky_color: Color = Color(0.3, 0.5, 0.8)  # Blue

## Terrain Data
var terrain_image: Image
var terrain_texture: ImageTexture
var terrain_sprite: Sprite2D
var collision_shape: CollisionPolygon2D

## Height map for quick access
var height_map: PackedInt32Array

func _ready() -> void:
	generate_terrain()

func generate_terrain(seed_value: int = -1) -> void:
	"""Generate procedural terrain using Perlin-like noise"""
	if seed_value > 0:
		seed(seed_value)

	# Create terrain image
	terrain_image = Image.create(terrain_width, terrain_height, false, Image.FORMAT_RGBA8)

	# Fill with sky color first
	terrain_image.fill(sky_color)

	# Generate height map using midpoint displacement
	height_map = PackedInt32Array()
	height_map.resize(terrain_width)

	# Initialize with base height
	for x in range(terrain_width):
		height_map[x] = base_height

	# Apply midpoint displacement for interesting terrain
	midpoint_displacement()

	# Smooth the terrain
	smooth_terrain(2)

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

	print("Terrain generated: %dx%d" % [terrain_width, terrain_height])

func midpoint_displacement() -> void:
	"""Generate terrain using midpoint displacement algorithm"""
	var segment_size = terrain_width / 4
	var variance = roughness

	while segment_size > 1:
		for i in range(0, terrain_width - segment_size, segment_size):
			var left = height_map[i]
			var right = height_map[min(i + segment_size, terrain_width - 1)]
			var mid_index = i + segment_size / 2

			if mid_index < terrain_width:
				# Calculate midpoint with random displacement
				var mid_height = (left + right) / 2.0
				mid_height += randf_range(-variance, variance)
				mid_height = clamp(mid_height, 100, terrain_height - 100)
				height_map[mid_index] = int(mid_height)

		# Reduce variance and segment size
		variance *= 0.5
		segment_size = segment_size / 2

func smooth_terrain(iterations: int = 1) -> void:
	"""Smooth terrain using moving average"""
	for _iter in range(iterations):
		var new_heights = PackedInt32Array()
		new_heights.resize(terrain_width)

		for x in range(terrain_width):
			var sum = 0
			var count = 0

			# Average with neighbors
			for dx in range(-1, 2):
				var nx = x + dx
				if nx >= 0 and nx < terrain_width:
					sum += height_map[nx]
					count += 1

			new_heights[x] = sum / count

		height_map = new_heights

func destroy_terrain(position: Vector2, radius: float, add_dirt: bool = false) -> void:
	"""Destroy (or add) terrain at position with given radius"""
	var center_x = int(position.x)
	var center_y = int(position.y)

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
			if pixel.a > 0.5 and pixel.distance_to(terrain_color) < 0.1:
				height = y
				break
		height_map[x] = height if height > 0 else terrain_height

func get_height_at(x: float) -> float:
	"""Get terrain height at x position"""
	var ix = int(x)
	if ix >= 0 and ix < terrain_width:
		return height_map[ix]
	return terrain_height

func is_solid_at(position: Vector2) -> bool:
	"""Check if position is solid terrain"""
	var x = int(position.x)
	var y = int(position.y)

	if x < 0 or x >= terrain_width or y < 0 or y >= terrain_height:
		return false

	var pixel = terrain_image.get_pixel(x, y)
	return pixel.distance_to(terrain_color) < 0.1

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
	var spacing = terrain_width / (total + 1)
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

func set_desert_theme() -> void:
	"""Set desert terrain colors"""
	terrain_color = Color(0.93, 0.79, 0.55)  # Sandy yellow
	sky_color = Color(0.53, 0.81, 0.92)  # Light blue
	generate_terrain()

func set_mountain_theme() -> void:
	"""Set mountain terrain colors"""
	terrain_color = Color(0.5, 0.5, 0.5)  # Grey
	sky_color = Color(0.3, 0.5, 0.8)  # Sky blue
	generate_terrain()

func set_lunar_theme() -> void:
	"""Set lunar terrain colors"""
	terrain_color = Color(0.4, 0.4, 0.4)  # Dark grey
	sky_color = Color(0.05, 0.05, 0.1)  # Dark space
	generate_terrain()

func set_volcanic_theme() -> void:
	"""Set volcanic terrain colors"""
	terrain_color = Color(0.3, 0.1, 0.1)  # Dark red
	sky_color = Color(0.4, 0.2, 0.1)  # Orange haze
	generate_terrain()
