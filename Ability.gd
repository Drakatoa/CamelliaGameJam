class_name Ability

extends Node

@export var primary_cooldown_time = 0.1  # Time between uses
var can_use_primary = true

@export var ult_cooldown_time = 10.0  # Cooldown for abilities (including ultimate)
var can_use_ult = true  # Whether the ability can currently be used
var current_crater = null  # Stores the current crater instance

#@export var fade_duration = 1.0  # Time for the fade-out effect


func spawn_crater(crater_position):
	# Remove the previous crater if it exists
	#if current_crater and current_crater.is_queued_for_deletion() == false:
		#fade_and_free(current_crater, 1)

	# Load and spawn the crater
	var crater_scene = preload("res://crater.tscn")  # Path to the crater scene
	await get_tree().create_timer(59.0/24.0/2.0).timeout
	var crater = crater_scene.instantiate()
	get_tree().current_scene.add_child(crater)
	crater.position = crater_position  # Position the crater
	current_crater = crater  # Store the reference to the current crater
	await get_tree().create_timer(10.0).timeout
	fade_and_free(current_crater, 5)

func fade_and_free(object: Node2D, fade_duration):
	if object and object.is_queued_for_deletion() == false:
		var tween = object.create_tween()
		tween.tween_property(object, "modulate:a", 0.0, fade_duration)
		tween.tween_callback(Callable(object, "queue_free"))

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
	spawn_crater(spawn_position)

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
