extends Area2D

@export var speed = 500  # Projectile speed
@export var lifetime = 2.0  # Time before it disappears
@export var frequency = 2.0  # Frequency of the sine wave
@export var amplitude = 4.0  # Amplitude of the sine wave
@export var is_sin: bool = true
var traveled_distance = 0.0
var elapsed_time = 0.0
@export var tilemap_path: NodePath = NodePath("/root/Node2D/TileMap") # Export a NodePath variable
var tilemap: TileMap
var direction = Vector2.ZERO  # Direction the projectile travels in

# Load the TileMap script to access its properties
var tilemap_script = preload("res://tile_map.gd")

func _ready():
	if has_node(tilemap_path):
		tilemap = get_node(tilemap_path) as TileMap
		if tilemap:
			print("TileMap loaded successfully.")
		else:
			print("TileMap path is correct but node is not a TileMap.")
	else:
		print("TileMap does not exist at path:", tilemap_path)

	# Use await to remove the projectile after its lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	# Move the projectile in its direction
	traveled_distance += speed * delta
	var straight_movement = direction * speed * delta
	elapsed_time += delta
	var offset
	if is_sin:
		offset = Vector2(
			-direction.y,  # Perpendicular to the straight movement (x component)
			direction.x    # Perpendicular to the straight movement (y component)
		).normalized() * sin(elapsed_time * TAU * frequency) * amplitude
	else:
		offset = Vector2(
			direction.y,  # Perpendicular to the straight movement (x component)
			-direction.x    # Perpendicular to the straight movement (y component)
		).normalized() * sin(elapsed_time * TAU * frequency) * amplitude
	var movement = straight_movement + offset
	position += movement
	if direction != Vector2.ZERO:
		rotation = movement.angle()

	# Check for collision with the TileMap
	if tilemap and tilemap is TileMap:
		var grid_position = tilemap.local_to_map(position)
		if tilemap.get_cell_source_id(tilemap_script.layers.level0, grid_position) == -1:
			print("it gone")
			queue_free()

func _on_body_entered(body):
	# Handle collision with enemies
	if body.is_in_group("enemies"):
		queue_free()  # Destroy projectile on collision
