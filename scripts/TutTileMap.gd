extends TileMap

@onready var timer = $WaterTimer
var delay = 0.25
var min: int = -50
var max: int = min * -1

func _ready():
	timer.set_wait_time(delay)
	timer.set_one_shot(false)
	timer.start()

func _on_water_timer_timeout():
	var current_tile: Vector2i
	var farm_tile: Vector2i
	var farm_tile_id: int
	var current_x: int
	var current_y: int
	for y in range(min,max+1):
		for x in range(min,max+1):
			#if get_cell_source_id(1, Vector2(x, y)) == 1:
				#farm_tile = get_cell_atlas_coords(1, Vector2i(x,y))
				##current_x = farm_tile.x
				##current_y = farm_tile.y
				#if farm_tile.y == 0:
					#if farm_tile.x == 3:
						#set_cell(1, Vector2(x, y), 1, Vector2i(0,0), 0)
					#else:
						#set_cell(1, Vector2(x, y), 1, Vector2i(farm_tile.x+1,0), 0)
			#else:
			current_tile = get_cell_atlas_coords(0, Vector2i(x,y))
			current_x = current_tile.x
			if current_x == 3:
				set_cell(0, Vector2(x, y), 5, Vector2i(0,0), 0)
			else:
				set_cell(0, Vector2(x, y), 5, Vector2i(current_x+1,0), 0)
