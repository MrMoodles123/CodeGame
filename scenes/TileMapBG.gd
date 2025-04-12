extends TileMap
var min: int = -50
var max: int = min * -1

func _ready():
	gen_bg_water()

func gen_bg_water():
	z_index = -1
	scale = Vector2(5,5)
	
	var curr_tile: int = 0
	for y in range(min,max+1):
		curr_tile = 0
		for x in range(min,max+1):
			set_cell(0, Vector2(x, y), 5, Vector2i(curr_tile,0), 0)
			if curr_tile == 3:
				curr_tile = 0
			else:
				curr_tile += 1

func _on_timer_timeout():
	var current_tile: Vector2i
	var current_x: int
	for y in range(min,max+1):
		for x in range(min,max+1):
			current_tile = get_cell_atlas_coords(0, Vector2i(x,y))
			current_x = current_tile.x
			if current_x == 3:
				set_cell(0, Vector2(x, y), 5, Vector2i(0,0), 0)
			else:
				set_cell(0, Vector2(x, y), 5, Vector2i(current_x+1,0), 0)
