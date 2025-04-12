# class that represents the 2D grid
class_name Grid
# enum that represents the type of states a tile can be in
enum STATES {GRASS, WATER, CROP, ROCK}
# attributes
var grid = []
var size: int
var lvl_number : int
var crops_collected: int = 0
var crops_needed: int = 50
var crops_required: int = 0
var rocks_needed: int = 0
var rocks_remaining: int = 0
var rng = RandomNumberGenerator.new()
# arrays that act like a queue, these store co-ords of the next grid tile that needs to be updated
var queue_x = []
var queue_y = []
# final grid state to check if level is cleared
var final_grid = []
# attribute to store error locations
var error_locations = []


# constructor
func _init(g_size: int, lvl_num: int):
	size = g_size
	lvl_number = lvl_num
	for i in size:
		grid.append([])
		final_grid.append([])
		for j in size:
			grid[i].append(STATES.GRASS)
			final_grid[i].append(STATES.GRASS)
	# generate river in random row
	#var water_pos = rng.randi_range(2,7)
	#for x in size:
		#set_water(x,water_pos)
	# generate the rocks
	#gen_rocks()
	#set_crop_locations(water_pos)
	add_water_features(lvl_num)
	gen_rocks()
	set_crops_required()

# function to generate a random number of rocks and place them in random spots on the grid
func gen_rocks():
	#var num_rocks = rng.randi_range(5,10)
	var num_rocks = int(size * size * (0.05 + 0.02 * lvl_number))
	var done = false
	var rocks_placed = 0
	while !done:
		var rock_x = rng.randi_range(0,size - 1)
		var rock_y = rng.randi_range(0,size - 1)
		var placed = place_rock(rock_x, rock_y)
		if placed:
			rocks_placed += 1
		if rocks_placed == num_rocks:
			rocks_remaining = rocks_placed
			rocks_needed = rocks_placed
			done = true

# function to get the x co-ord of the next tile that needs to be updated
func get_next_x():
	return queue_x.pop_front()

# function to get the y co-ord of the next tile that needs to be updated
func get_next_y():
	return queue_y.pop_front()

# function to update a grid tile with a given state
func update_tile(x: int, y: int, state: STATES):
	grid[y][x] = state

# function to update a final grid tile with a given state
func update_final_tile(x: int, y: int, state: STATES):
	final_grid[y][x] = state

# function that gets the state of a given tile co-ords
func get_state(x: int, y: int):
	if x >= size or y >= size:
		return
		
	return grid[y][x]


# function to plant crop on a given tile if possible
# returns true if planted or false if a crop cannot be planted on the tile
func plant_crop(x: int, y: int):
	if (!is_plantable(x, y)):
		return false
	update_tile(x, y, STATES.CROP)
	# add co-ords to queue for updating display
	queue_x.push_back(x)
	queue_y.push_back(y)
	return true
	
# function to remove a rock on a given tile if possible
# returns true if removed or false if no rock on tile to remove
func break_rock(x: int, y: int):
	if (get_state(x, y) == STATES.ROCK):
		update_tile(x, y, STATES.GRASS)
		# add co-ords to queue for updating display
		queue_x.push_back(x)
		queue_y.push_back(y)
		rocks_remaining -= 1
		return true
	return false

# function to harvest a crop on a given tile if possible
# returns true if harvested or false if no crop on tile to harvest
func harvest(x: int, y: int):
	if (get_state(x, y) == STATES.CROP):
		update_tile(x, y, STATES.GRASS)
		# add co-ords to queue for updating display
		queue_x.push_back(x)
		queue_y.push_back(y)
		#crops_harvested += 1
		return true
	return false

# function to set the number of crops required to complete the level
func set_crops_required():
	crops_required = (size*2) * (1 + (0.25*(lvl_number-1)))

# sets the final grid up with all the locations of where crops should be
func set_crop_locations(water_pos: int):
	for x in size:
		if water_pos < (size - 1):
			update_final_tile(x, water_pos + 1, STATES.CROP)
		if water_pos > 1:
			update_final_tile(x, water_pos - 1, STATES.CROP)

# function that sets the tile to water of both grids
func set_water(x: int, y: int):
	update_tile(x, y, STATES.WATER)
	update_final_tile(x, y, STATES.WATER)

# function to place a rock on a given tile if possible
# returns true if placed or false if a rock cannot be placed on the tile
func place_rock(x: int, y: int):
	if (get_state(x, y) != STATES.GRASS):
		return false
	update_tile(x, y, STATES.ROCK)
	return true

# check if a crop can be planted on a tile
func is_plantable(x: int, y: int):
	# ensure tile is grass
	if (get_state(x,y) != STATES.GRASS): 
		return false
	# check if any adjacent tile is water
	if (x > 0):
		if (get_state(x-1,y) == STATES.WATER):
			return true
	if (x < size - 1):
		if (get_state(x+1,y) == STATES.WATER):
			return true
	if (y > 0):
		if (get_state(x,y-1) == STATES.WATER):
			return true
	if (y < size - 1):
		if (get_state(x,y+1) == STATES.WATER):
			return true
			
	return false # if no adjacent tile is water, return false

# function check if the grid goals have been completed
func is_completed(crops_harvested: int):
	print("rocks rem: " + str(rocks_remaining))
	if (rocks_remaining <= 0) and (crops_harvested >= crops_needed):
		
		SilentWolf.Scores.save_score()
		return true
	else:
		return false

# function to get the number of crops still needed to be harvested
func get_crops_required():
	return crops_required

func get_rocks_needed():
	return rocks_needed

func get_remaining_rocks():
	return rocks_remaining

# print grid for debugging
func print_grid():
	for x in size:
		print(grid[x])
		
# print final_grid for debugging
func print_final_grid():
	for x in size:
		print(final_grid[x])
		
# function to generate water features based on the level of the challenge
func add_water_features(level_number: int):
	if level_number == 1:
		# Simple river
		var orientation = rng.randi_range(0,1) # randomly choose if river is vertical or horizontal (0 = vertical, 1 = horizontal)
		if orientation == 0:
			var river_x = rng.randi_range(2, size - 3)
			for y in range(size):
				update_tile(river_x, y, STATES.WATER)
				update_final_tile(river_x, y, STATES.WATER)
		else:
			var river_y = rng.randi_range(2, size - 3)
			for x in range(size):
				update_tile(x, river_y, STATES.WATER)
				update_final_tile(x, river_y, STATES.WATER)
	elif level_number == 2:
		# Winding river
		var orientation = rng.randi_range(0,1) # randomly choose if river is vertical or horizontal (0 = vertical, 1 = horizontal)
		if orientation == 0:
			var x = rng.randi_range(2, size - 3)
			for y in range(size):
				update_tile(x, y, STATES.WATER)
				update_final_tile(x, y, STATES.WATER)
				x += rng.randi_range(-1, 1)
				x = clamp(x, 1, size - 2)
		else:
			var y = rng.randi_range(2, size - 3)
			for x in range(size):
				update_tile(x, y, STATES.WATER)
				update_final_tile(x, y, STATES.WATER)
				y += rng.randi_range(-1, 1)
				y = clamp(y, 1, size - 2)
	elif level_number == 3:
		# River with a lake
		add_water_features(2)  # Add a winding river
		var lake_center_x = rng.randi_range(size/4, 3*size/4)
		var lake_center_y = rng.randi_range(size/4, 3*size/4)
		var lake_radius = size / 8
		for x in range(max(0, lake_center_x - lake_radius), min(size, lake_center_x + lake_radius + 1)):
			for y in range(max(0, lake_center_y - lake_radius), min(size, lake_center_y + lake_radius + 1)):
				if (x - lake_center_x)**2 + (y - lake_center_y)**2 <= lake_radius**2:
					update_tile(x, y, STATES.WATER)
					update_final_tile(x, y, STATES.WATER)
	elif level_number == 4:
		# Two intersecting rivers
		# Add a vertical river
		var river_x = rng.randi_range(2, size - 3)
		for y in range(size):
			update_tile(river_x, y, STATES.WATER)
			update_final_tile(river_x, y, STATES.WATER)
		# Add a horizontal river
		var y = rng.randi_range(2, size - 3)
		for x in range(size):
			update_tile(x, y, STATES.WATER)
			update_final_tile(x, y, STATES.WATER)
	else:
		# Complex water system
		add_water_features(4)  # Two intersecting rivers
		add_water_features(3)  # Add a lake

