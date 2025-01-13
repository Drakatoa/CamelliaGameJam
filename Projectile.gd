extends Area2D

@export var speed = 500  # Projectile speed
@export var lifetime = 2.0  # Time before it disappears
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
	position += direction * speed * delta
	if direction != Vector2.ZERO:
		rotation = direction.angle() 

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
