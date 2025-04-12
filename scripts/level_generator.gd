# glass that generates a new level
class_name LevelGenerator extends Node

# generates the level given the level number
func generate_level(level_number):
	var grid_size = get_grid_size(level_number)
	var grid = Grid.new(grid_size, level_number)

	return grid

# returns the size (length) of the grid
func get_grid_size(level_number):
	return 8 + (level_number - 1) * 3  # 8x8 for level 1, 14x14 for level 2, ..., 32x32 for level 5

