extends Area2D

@export var speed = 500  # Projectile speed
@export var lifetime = 2.0  # Time before it disappears

var direction = Vector2.ZERO  # Direction the projectile travels in

@export var tilemap_path: NodePath  # Export a NodePath variable
var tilemap: TileMap

# Load the TileMap script to access its properties
var tilemap_script = preload("res://tile_map.gd")

func _ready():
	tilemap = get_node(tilemap_path) as TileMap
	# Use await to remove the projectile after its lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	# Move the projectile in its direction
	position += direction * speed * delta
	if direction != Vector2.ZERO:
		rotation = direction.angle() 
	# Check for collision with the TileMap
	var tilemap = get_tree().root.find_child("TileMap", true)
	if tilemap:
		var grid_position = tilemap.world_to_map(position)  # Convert position to grid coordinates
		# Use the imported layers enum
		if tilemap.get_cell_source_id(tilemap_script.layers.level0, grid_position) != -1:
			queue_free()

func _on_body_entered(body):
	# Handle collision with enemies
	if body.is_in_group("enemies"):
		queue_free()  # Destroy projectile on collision
