# the grid / tiles linked with the HomeGrid
class_name HomeGrid extends Grid

# constructor
func _init(g_size):
	size = g_size
	for i in size:
		grid.append([])
		for j in size:
			grid[i].append(STATES.GRASS)
	gen_water()

# generate a winding horizontal river
func gen_water():
	var y = rng.randi_range(2, size - 3)
	for x in range(size):
		update_tile(x, y, STATES.WATER)
		#update_final_tile(x, y, STATES.WATER)
		y += rng.randi_range(-1, 1)
		y = clamp(y, 1, size - 2)
		
# check if there is a crop planted anywhere
func contains_crop():
	for x in size:
		for y in size:
			if get_state(x,y) == STATES.CROP:
				return true
	return false

# check if there is a rock placed anywhere
func contains_rock():
	for x in size:
		for y in size:
			if get_state(x,y) == STATES.ROCK:
				return true
	return false

# check if there is an open grass spot available for a rock
func has_grass():
	for x in size:
		for y in size:
			if get_state(x,y) == STATES.GRASS:
				return true
	return false

# check if there is an open spot to plant a crop on
func has_plant_spot():
	for x in size:
		for y in size:
			if is_plantable(x,y):
				return true
	return false
