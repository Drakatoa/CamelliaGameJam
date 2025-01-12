class_name Ability

extends Node

@export var cooldown_time = 0.1  # Time between uses
var can_use = true

func use_ability(caller, spawn_position, direction):
	if can_use:
		can_use = false
		spawn_projectile(spawn_position, direction)
		# Use await to enforce cooldown
		await get_tree().create_timer(cooldown_time).timeout
		can_use = true

func spawn_projectile(spawn_position, direction):
	# Load and spawn the projectile
	var projectile_scene = preload("res://projectile.tscn")
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.position = spawn_position
	projectile.direction = direction.normalized()
