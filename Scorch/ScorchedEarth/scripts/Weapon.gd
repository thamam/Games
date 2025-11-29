extends Resource
class_name Weapon

## Weapon Resource - Defines weapon properties
## Used by shop and firing system

@export var weapon_id: String = ""
@export var weapon_name: String = "Unknown"
@export var description: String = ""
@export var cost: int = 100
@export var damage: int = 30
@export var explosion_radius: float = 30.0
@export var projectile_scene: PackedScene
@export var icon_color: Color = Color.WHITE

## Weapon behavior
@export var is_dirt_weapon: bool = false
@export var adds_terrain: bool = false
@export var gravity_scale: float = 1.0
@export var wind_resistance: float = 0.5
@export var bounce_factor: float = 0.0
@export var max_bounces: int = 0

## Special weapon properties
@export var is_mirv: bool = false
@export var is_cluster_bomb: bool = false
@export var is_guided: bool = false
@export var heat_seeking: bool = false
@export var splits_count: int = 0

func create_projectile():
	"""Create a projectile instance for this weapon (untyped to avoid circular dependency)"""
	var projectile  # Projectile instance

	# Create specific projectile type
	var ProjectileScript = load("res://scripts/Projectile.gd")
	if is_mirv:
		projectile = ProjectileScript.MIRVProjectile.new()
	elif is_cluster_bomb:
		projectile = ProjectileScript.FunkyBombProjectile.new()
	elif is_guided:
		projectile = ProjectileScript.GuidedMissileProjectile.new()
	elif heat_seeking:
		projectile = ProjectileScript.HeatSeekingProjectile.new()
	else:
		projectile = ProjectileScript.new()

	# Set properties
	projectile.damage = damage
	projectile.explosion_radius = explosion_radius
	projectile.is_dirt_weapon = is_dirt_weapon or adds_terrain
	projectile.gravity_scale = gravity_scale
	projectile.wind_resistance = wind_resistance
	projectile.bounce_factor = bounce_factor
	projectile.max_bounces = max_bounces
	projectile.projectile_color = icon_color

	return projectile

## Weapon Database - Static weapon definitions

static func get_all_weapons() -> Array:
	"""Get all available weapons"""
	return [
		create_baby_missile(),
		create_missile(),
		create_heavy_missile(),
		create_baby_nuke(),
		create_nuke(),
		create_mirv(),
		create_funky_bomb(),
		create_guided_missile(),
		create_heat_seeker(),
		create_napalm(),
		create_roller(),
		create_leapfrog(),
		create_dirt_ball(),
		create_dirt_slapper(),
		create_dirt_charge(),
	]

static func get_weapon_by_id(id: String):
	"""Get weapon by ID"""
	var weapons = get_all_weapons()
	for weapon in weapons:
		if weapon.weapon_id == id:
			return weapon
	return create_missile()  # Default

## Individual Weapon Definitions

static func create_baby_missile():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "baby_missile"
	w.weapon_name = "Baby Missile"
	w.description = "Small, cheap projectile"
	w.cost = 100
	w.damage = 15
	w.explosion_radius = 20.0
	w.icon_color = Color.YELLOW
	return w

static func create_missile():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "missile"
	w.weapon_name = "Missile"
	w.description = "Standard projectile"
	w.cost = 500
	w.damage = 30
	w.explosion_radius = 30.0
	w.icon_color = Color.ORANGE
	return w

static func create_heavy_missile():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "heavy_missile"
	w.weapon_name = "Heavy Missile"
	w.description = "Large explosive"
	w.cost = 1500
	w.damage = 70
	w.explosion_radius = 50.0
	w.icon_color = Color.DARK_ORANGE
	return w

static func create_baby_nuke():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "baby_nuke"
	w.weapon_name = "Baby Nuke"
	w.description = "Medium nuclear weapon"
	w.cost = 2500
	w.damage = 90
	w.explosion_radius = 70.0
	w.icon_color = Color.RED
	return w

static func create_nuke():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "nuke"
	w.weapon_name = "Nuke"
	w.description = "Massive destruction"
	w.cost = 5000
	w.damage = 120
	w.explosion_radius = 100.0
	w.icon_color = Color.DARK_RED
	return w

static func create_mirv():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "mirv"
	w.weapon_name = "MIRV"
	w.description = "Splits into 5 warheads"
	w.cost = 3000
	w.damage = 25
	w.explosion_radius = 25.0
	w.is_mirv = true
	w.splits_count = 5
	w.icon_color = Color.CYAN
	return w

static func create_funky_bomb():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "funky_bomb"
	w.weapon_name = "Funky Bomb"
	w.description = "Scatters 8 submunitions"
	w.cost = 2000
	w.damage = 20
	w.explosion_radius = 25.0
	w.is_cluster_bomb = true
	w.max_bounces = 3
	w.bounce_factor = 0.7
	w.icon_color = Color.MAGENTA
	return w

static func create_guided_missile():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "guided_missile"
	w.weapon_name = "Guided Missile"
	w.description = "Player-controlled flight"
	w.cost = 2500
	w.damage = 50
	w.explosion_radius = 40.0
	w.is_guided = true
	w.icon_color = Color(1.0, 0.8, 0.0)  # Gold
	return w

static func create_heat_seeker():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "heat_seeker"
	w.weapon_name = "Heat Seeker"
	w.description = "Tracks nearest tank"
	w.cost = 3500
	w.damage = 60
	w.explosion_radius = 45.0
	w.heat_seeking = true
	w.icon_color = Color(1.0, 0.3, 0.0)  # Orange-red
	return w

static func create_napalm():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "napalm"
	w.weapon_name = "Napalm"
	w.description = "Incendiary bouncing weapon"
	w.cost = 1800
	w.damage = 35
	w.explosion_radius = 35.0
	w.max_bounces = 2
	w.bounce_factor = 0.6
	w.icon_color = Color(1.0, 0.5, 0.0)
	return w

static func create_roller():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "roller"
	w.weapon_name = "Roller"
	w.description = "Rolls down slopes"
	w.cost = 800
	w.damage = 40
	w.explosion_radius = 30.0
	w.gravity_scale = 2.0
	w.max_bounces = 5
	w.bounce_factor = 0.8
	w.icon_color = Color.GREEN
	return w

static func create_leapfrog():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "leapfrog"
	w.weapon_name = "Leapfrog"
	w.description = "Multiple bounces before detonation"
	w.cost = 1200
	w.damage = 45
	w.explosion_radius = 35.0
	w.max_bounces = 4
	w.bounce_factor = 0.75
	w.icon_color = Color.LIME
	return w

static func create_dirt_ball():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "dirt_ball"
	w.weapon_name = "Dirt Ball"
	w.description = "Adds terrain"
	w.cost = 200
	w.damage = 0
	w.explosion_radius = 25.0
	w.is_dirt_weapon = true
	w.adds_terrain = true
	w.icon_color = Color.BROWN
	return w

static func create_dirt_slapper():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "dirt_slapper"
	w.weapon_name = "Dirt Slapper"
	w.description = "Large dirt deposit"
	w.cost = 500
	w.damage = 0
	w.explosion_radius = 50.0
	w.is_dirt_weapon = true
	w.adds_terrain = true
	w.icon_color = Color.SADDLE_BROWN
	return w

static func create_dirt_charge():
	var WeaponScript = load("res://scripts/Weapon.gd")
	var w = WeaponScript.new()
	w.weapon_id = "dirt_charge"
	w.weapon_name = "Dirt Charge"
	w.description = "Removes terrain"
	w.cost = 300
	w.damage = 0
	w.explosion_radius = 30.0
	w.is_dirt_weapon = true
	w.adds_terrain = false
	w.icon_color = Color.DARK_GRAY
	return w
