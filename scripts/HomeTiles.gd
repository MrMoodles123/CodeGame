# Visual grid on home screen that randomly changes with crops and rocks randomly being placed and removed
extends TileMap

var curr_grid_size: int = 8
var tiles = HomeGrid.new(curr_grid_size)
var rng = RandomNumberGenerator.new()

@onready var timer = $Timer

# update a tile given its co-ords and the state to update it to
func update_tile(x, y, state):
	match (state):
		Grid.STATES.GRASS:
			erase_cell(2, Vector2(x, y))
		Grid.STATES.CROP:
			set_cell(2, Vector2(x, y), 3, Vector2i(4,0), 0)
		Grid.STATES.ROCK:
			set_cell(2, Vector2(x, y), 4, Vector2i(0,1), 0)

# ready function called when loaded
func _ready():
	gen_display()
	# place a random mumber of objects on the grid
	var num_initial_objects = randi_range(7,12)
	for i in num_initial_objects:
		place_object()
	timer.start(2) # wait 2 seconds before starting to randomly place or remove an object

# generate the intitial display grid
func gen_display():
	# grass corners
	set_cell(1, Vector2(0, 0), 0, Vector2i(0,0), 0)
	set_cell(1, Vector2(0, curr_grid_size-1), 0, Vector2i(0,2), 0)
	set_cell(1, Vector2(curr_grid_size-1, 0), 0, Vector2i(2,0), 0)
	set_cell(1, Vector2(curr_grid_size-1, curr_grid_size-1), 0, Vector2i(2,2), 0)
	# grass sides
	for i in range(1,curr_grid_size-1):
		set_cell(1, Vector2(0, i), 0, Vector2i(0,1), 0)
		set_cell(1, Vector2(curr_grid_size-1, i), 0, Vector2i(2,1), 0)
		set_cell(1, Vector2(i, 0), 0, Vector2i(1,0), 0)
		set_cell(1, Vector2(i, curr_grid_size-1), 0, Vector2i(1,2), 0)
	# rest of grass insides
	for x in range(1,curr_grid_size-1):
		for y in range(1,curr_grid_size-1):
			set_cell(1, Vector2(x, y), 0, Vector2i(0,5), 0)
	# other states
	for x in curr_grid_size:
		for y in curr_grid_size:
			match tiles.get_state(x,y):
				Grid.STATES.WATER:
					var x_tile: int
					var y_tile: int
					if x == 0 and y == 0:
						x_tile = 0
						y_tile = 2
					elif x == 0 and y == (curr_grid_size - 1):
						x_tile = 2
						y_tile = 2
					elif x == (curr_grid_size - 1) and y == 0:
						x_tile = 1
						y_tile = 2
					elif x == (curr_grid_size - 1) and y == (curr_grid_size - 1):
						x_tile = 3
						y_tile = 2
					elif x == 0:
						x_tile = 0
						y_tile = 1
					elif x == (curr_grid_size - 1):
						x_tile = 1
						y_tile = 1
					elif y == 0:
						x_tile = 2
						y_tile = 1
					elif y == (curr_grid_size - 1):
						x_tile = 2
						y_tile = 1
					else:
						x_tile = 0
						y_tile = 0
						
					set_cell(1, Vector2(x, y), 1, Vector2i(x_tile,y_tile), 0)
				Grid.STATES.CROP:
					set_cell(2, Vector2(x, y), 3, Vector2i(4,0), 0)
				Grid.STATES.ROCK:
					set_cell(2, Vector2(x, y), 4, Vector2i(0,1), 0)

# find a place to plant a crop
func plant():
	var done: bool = false
	var x
	var y
	while !done:
		x = rng.randi_range(0,7)
		y = rng.randi_range(0,7)
		done = tiles.plant_crop(x,y)
		
	update_tile(x, y, Grid.STATES.CROP)

# find a place to place a rock
func place_rock():
	var done: bool = false
	var x
	var y
	while !done:
		x = rng.randi_range(0,7)
		y = rng.randi_range(0,7)
		done = tiles.place_rock(x, y)
		
	update_tile(x, y, Grid.STATES.ROCK)

# find a crop to harvest
func harvest():
	var done: bool = false
	var x
	var y
	while !done:
		x = rng.randi_range(0,7)
		y = rng.randi_range(0,7)
		done = tiles.harvest(x, y)
		
	update_tile(x, y, Grid.STATES.GRASS)
	
# find a rock to break
func break_rock():
	var done: bool = false
	var x
	var y
	while !done:
		x = rng.randi_range(0,7)
		y = rng.randi_range(0,7)
		done = tiles.break_rock(x, y)
		
	update_tile(x, y, Grid.STATES.GRASS)

# place either a rock or crop randomly
func place_object():
	var done: bool = false
	while !done:
		var num = rng.randi_range(0,1)
		match (num):
			0: # plant crop
				if tiles.has_plant_spot():
					plant()
					done = true
			1: # place rock
				if tiles.has_grass():
					place_rock()
					done = true

# called when timer expires, randomly either place an object, or break / harvest one
func _on_timer_timeout():
	var done: bool = false
	while !done:
		var num = rng.randi_range(0,3)
		match (num):
			0: # plant crop
				if tiles.has_plant_spot():
					plant()
					done = true
			1: # harvest
				if tiles.contains_crop():
					harvest()
					done = true
			2: # place rock
				if tiles.has_grass():
					place_rock()
					done = true
			3: # break rock
				if tiles.contains_rock():
					break_rock()
					done = true
	timer.start(rng.randf_range(0.2,0.5)) # restart timer with a random time
