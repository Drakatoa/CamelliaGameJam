extends TileMap

enum layers{
	level0=0,
	level1=1,
	level2=2,
}

const boundary_atlas_pos = Vector2i(0,1)
const main_source = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	place_boundaries()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func place_boundaries():
	var offsets = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(1, 0),
		Vector2i(-1, 0),
	]
	var used = get_used_cells(layers.level0)
	for spot in used:
		for offset in offsets:
			var current_spot = spot+offset
			if get_cell_source_id(layers.level0, current_spot) == -1:
				set_cell(layers.level0, current_spot, main_source, boundary_atlas_pos)
					
