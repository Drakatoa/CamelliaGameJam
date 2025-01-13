class_name Ability

extends Node

@export var primary_cooldown_time = 0.1  # Time between uses
var can_use_primary = true

@export var ult_cooldown_time = 10.0  # Cooldown for abilities (including ultimate)
var can_use_ult = true  # Whether the ability can currently be used

func use_ult(caller, spawn_position):
	if can_use_ult:
		can_use_ult = false
		spawn_ultimate(spawn_position)
		# Start cooldown
		start_cooldown()

func spawn_ultimate(spawn_position):
	# Load and spawn the ultimate
	var ultimate_scene = preload("res://ultimate.tscn")  # Path to ultimate scene
	var ultimate = ultimate_scene.instantiate()
	get_tree().current_scene.add_child(ultimate)
	ultimate.position = spawn_position  # Position the ultimate

func start_cooldown():
	await get_tree().create_timer(ult_cooldown_time).timeout
	can_use_ult = true

func use_ability(caller, spawn_position, direction, is_sin):
	if can_use_primary:
		can_use_primary = false
		spawn_projectile(spawn_position, direction, is_sin)
		# Use await to enforce cooldown
		await get_tree().create_timer(primary_cooldown_time).timeout
		can_use_primary = true

func spawn_projectile(spawn_position, direction, is_sin):
	# Load and spawn the projectile
	var projectile_scene = preload("res://projectile.tscn")
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.position = spawn_position
	projectile.direction = direction.normalized()
	projectile.is_sin = is_sin
	print(is_sin)
