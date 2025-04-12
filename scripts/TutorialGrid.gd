class_name TutorialGrid extends Grid

func _init(g_size: int, tut_lvl: int):
	size = g_size
	for i in size:
		grid.append([])
		final_grid.append([])
		for j in size:
			grid[i].append(STATES.GRASS)
			final_grid[i].append(STATES.GRASS)
			
	match tut_lvl:
		1,2,3,4,5:
			set_water(1, 1)
		6,7,8,9,10:
			for x in size:
				set_water(x,2)
			set_crop_location(2)
			
func place_tut_rock(x, y):
	update_tile(x, y, STATES.ROCK)
	queue_x.push_back(x)
	queue_y.push_back(y)
	
# function to generate a given number of rocks and place them in random spots on the grid
func gen_tut_rocks(num_rocks: int):
	var done = false
	var rocks_placed = 0
	while !done:
		var rock_x = rng.randi_range(0,size - 1)
		var rock_y = rng.randi_range(0,size - 1)
		var placed = place_rock(rock_x, rock_y)
		if placed:
			rocks_placed += 1
		if rocks_placed == num_rocks:
			done = true

func set_crop_location(water_pos: int):
	for x in size:
		update_final_tile(x, water_pos - 1, STATES.CROP)
		
# checks to see if current grid states match the final grid states
func is_done():
	for x in size:
		for y in size:
			if (grid[x][y] != final_grid[x][y]):
				return false
	return true
# tests to see if there is only grass or water present on the farm (i.e no rocks or crops)
func only_grass():
	print_grid()
	for x in size:
		for y in size:
			if (get_state(x,y) == STATES.CROP) or (get_state(x,y) == STATES.ROCK):
				return false
	return true
