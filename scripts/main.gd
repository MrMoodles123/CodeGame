# main class where everything runs
extends Node2D

class_name Game

# level generator
#const LevelGenerator = preload("res://scripts/level_generator.gd")
var level_generator
#var current_level = 1
# variables representing the different GUI components and nodes
@onready var tile_map = $TileMap # the display grid
@onready var camera = $Camera2D #scaling
@onready var code_edit = $CodeEdit # editor that the user types in
@onready var timer = $Timer # timer that updates display
@onready var output = $Output_Text_Box # text box where errors get displayed to user
@onready var run_button = $Button # the "run" button that the user presses
@onready var finish_panel = $Finish_Panel
@onready var finish_label = $Finish_Panel/Label
@onready var objectives_panel = $objectives_panel
@onready var objectives_label = $objectives_panel/Label
@onready var crops_label = $objectives_panel/Label 
@onready var count_up_timer = $Count_Up_Timer
@onready var timer_label = $Timer_Label
@onready var crop_counter = $CropCountLabel
@onready var crop_icon = $CropCountLabel/CropIcon
@onready var settings_menu = $MenuBG
@onready var next_button = $Finish_Panel/NextLvlButton
@onready var retry_button = $Finish_Panel/RetryButton
@onready var home_button = $Finish_Panel/HomeButton
@onready var fd_save = $DialogSave
@onready var fd_load = $DialogLoad
@onready var best_score_label = $BestScoreLabel
@onready var break_rock_audio = $SFXPlayer/BreakRockAudio
@onready var plant_audio = $SFXPlayer/PlantAudio
@onready var harvest_audio = $SFXPlayer/HarvestAudio
@onready var error_audio = $SFXPlayer/ErrorAudio
@onready var dialogue_box = $DialogueBoxPanel
@onready var help_timer = $HelpButton/HelpTimer

var size: int = 8 # size of grid
var rng = RandomNumberGenerator.new()
var tiles = Grid.new(size,1)
var expression = Expression.new()
var output_q = [] # strings to be outputted to outputlabel
var is_level_cleared = false # this is used to track if the level has been cleared or not
var total_time : int = 0 # total timer user takes to complete level (in seconds)
var num_erros : int = 0
var num_crops_harvested: int = 0
var num_rocks_broken: int = 0
var num_times_func_typed: int = 0
var num_times_button_pressed: int = 0 # tracks how many times user clicks the button
var num_times_help_pressed: int = 0
var level: int = 1
# setup for user code class, extends this class so user can call the methods of this class.
#const SC = "extends Game\nfunc update_grid(new_grid): tiles = new_grid\nfunc return_grid(): return tiles\nfunc get_out_q(): return output_q\nfunc exec():\n" 
const SC = "extends Game\nfunc update_grid(new_grid): tiles = new_grid\nfunc return_grid(): return tiles\nfunc get_out_q(): return output_q\nfunc set_crop_count(val): num_crops_harvested = val\nfunc get_crop_count(): return num_crops_harvested\n"
const BASE_GRID_SIZE = 8
const BASE_TILE_SIZE = 16  # Assuming each tile is 16x16 pixels
const BASE_SCALE = 3  # Your current scale

# ready function executes when game starts
func _ready():
	Global._check_user_scripts_dir()
	fd_load.root_subfolder = "user_scripts"
	fd_save.root_subfolder = "user_scripts"
	print("READY")
	for keyword in ["var", "if", "else", "elif", "for", "while", "in", "break", "pass", "continue", "func"]:
		code_edit.syntax_highlighter.add_keyword_color(keyword, Color("d8b1e0"))
	level_generator = LevelGenerator.new()
	level = Levels.challenge_level
	load_level(level) 
	reset()
	tiles.print_grid()
	print()
	tiles.print_final_grid()
	Dialogic.signal_event.connect(handle_dialogue)
	#settings_menu.hide()


# resets values and counts for game restart
func reset():
	clear_error_highlights()
	code_edit.size = Vector2(511/code_edit.scale.x,544/code_edit.scale.y)
	is_level_cleared = false
	finish_panel.visible = false
	objectives_panel.visible = false
	total_time = 0
	num_erros = 0
	num_crops_harvested = 0
	num_times_func_typed = 0
	num_rocks_broken = 0
	num_times_help_pressed = 0
	num_times_button_pressed = 0
	fd_save.visible = false
	fd_load.visible = false
	crop_counter.text = str(num_crops_harvested) + "/" + str(tiles.get_crops_required())
	var score = Global.current_player.best_scores[level-1]
	if score == 100000:
		best_score_label.text = "Level " + str(level) + " Best Score: N/A"
	else:
		best_score_label.text = "Level " + str(level) + " Best Score: " + str(score)
	crop_icon.global_position.x = crop_counter.position.x - 5 - 16#(crop_icon.scale.x*16)
	code_edit.text = "func execute():\n\t"
	count_up_timer.start()

# loads the level the user is playing, and sets up the level
func load_level(level_number):
	var new_grid_size = get_grid_size(level_number)
	scale_grid(new_grid_size)
	
	var new_grid = level_generator.generate_level(level_number)
	size = new_grid_size # Update the grid size
	tiles = new_grid  # Create a new Grid with the updated size
	tiles.set_crops_required()
	gen_display()  # Update the display
	# Update objectives and hints for the new level
	update_objectives(level_number)

# function that user calls to plant a crop on a given co-ord
func plant_crop(x, y):
	
	if _out_of_bounds_handler(x, y):
		return
	
	var planted = tiles.plant_crop(x, y)
	if planted:
		output_q.push_back("Crop planted successfully at (" + str(x) + ", " + str(y) + ")\n")
	else:
		output_q.push_back("ERROR: Crop could not be planted at (" + str(x) + ", " + str(y) + ")\n")
		#highlight_errors()
	print(planted)
	tiles.print_grid()

# function that user calls to break a rock on a given co-ord
func break_rock(x, y):
	
	if _out_of_bounds_handler(x, y):
		return
	
	var broken = tiles.break_rock(x, y)
	if broken:
		output_q.push_back("Rock removed successfully at (" + str(x) + ", " + str(y) + ")\n")
	else:
		output_q.push_back("ERROR: No rock to remove at (" + str(x) + ", " + str(y) + ")\n")
		#highlight_errors()
	print(broken)
	tiles.print_grid()
	#check_level_completion()

# function that user calls to harvest crop on a given co-ord
func harvest(x, y):
	
	if _out_of_bounds_handler(x, y):
		return
	
	var harvested = tiles.harvest(x, y)
	if harvested:
		output_q.push_back("Crop harvested successfully at (" + str(x) + ", " + str(y) + ")\n")
		num_crops_harvested += 1
	else:
		output_q.push_back("ERROR: No crop to harvest at (" + str(x) + ", " + str(y) + ")\n")
		#highlight_errors()
	print(harvested)
	tiles.print_grid()
	#check_level_completion()

#  function that user calls to checks if a crop can be planted on the given co-ords
func is_plantable(x, y):
	return tiles.is_plantable(x, y)

#  function that user calls to checks if a crop can be harvested on the given co-ords
func harvestable(x, y):
	return (get_state(x, y) == Grid.STATES.CROP)

#  function that user calls to checks if a rock is on the given co-ords
func is_rock(x, y):
	return (get_state(x, y) == Grid.STATES.ROCK)
	
# function that gets the state of a tile, using the co-ords of the tile
func get_state(x, y):
	var state = tiles.get_state(x, y)
	return state

# function that checks if a level is complete
func check_level_completion():
	if tiles.is_completed():
		end_level()

#func end_level():
	#is_level_cleared = true

# this function executes when user presses the "run" button
func _on_button_pressed():
	# disable button so user cannot spam it
	run_button.disabled = true
	clear_error_highlights()
	num_times_button_pressed += 1
	# create user script
	var user_script = GDScript.new()
	
	# checks for empty code editor
	if code_edit.text == "":
		output_q.push_back("No code entered\n")
		return

	var lines = code_edit.text.split("\n")	# stores each line as an array element
	var found = false
	var predefined_funcs = ["plant_crop(", "harvest(", "break_rock(", "is_plantable(", "harvestable(", "is_rock("]
	# search through each line of code and try to find main function declaration, and if any pre-defined functions have been overriden
	for i in range(lines.size()):
		var line: String = lines[i].strip_edges(false)
		if  line == "func execute():":
			found = true
		for f in predefined_funcs:
			if line.contains(f):
				num_times_func_typed += 1
			var pre_func = "func " + f
			if line.begins_with(pre_func):
				output_q.push_back("Function '" + f + "' is a predefined function and cannot be used a function name, please rename it\n")
				return
	if found == false:
		output_q.push_back("Main function 'func execute():' missing\n")
		return

	user_script.source_code = SC + code_edit.text # adds source code
	print(user_script.source_code)
	var error = user_script.reload()
	if error == OK:
		# create instance of script of execution
		var instance = user_script.new()
		instance.update_grid(tiles) # update tile grid
		instance.set_crop_count(num_crops_harvested) # update the number of crops harvested
		instance.execute() # execute user code
		tiles = instance.return_grid() # update grid
		output_q = instance.get_out_q() # get the output queue from the user script class
		# check if crops have been harvested and then update the number
		var crop_count = instance.get_crop_count()
		if crop_count != num_crops_harvested:
			#num_crops_harvested = crop_count
			# update crop counter to reflect amount of crops harvested
			crop_counter.text = str(num_crops_harvested) + "/" + str(tiles.get_crops_required())
			crop_icon.global_position.x = crop_counter.position.x - 5
		is_level_cleared = tiles.is_completed(num_crops_harvested)
	else:
		#clear_error_highlights() 
		output_q.push_back("SYNTAX ERROR in Code \n");

# Method to clear error highlights
func clear_error_highlights():
	tile_map.clear_layer(3)

# updates the display of a given tile
# set_cell: set_cell(layer, co-ords, atlas ID of tile set, atlas co-ords of image on the tile set, alternate tile)
# erase_cell: erase_cell(layer, co-ords)
func update_display(x, y):
	match tiles.get_state(x,y):
		Grid.STATES.CROP:
			tile_map.set_cell(2, Vector2(x, y), 3, Vector2i(4,0), 0)
		Grid.STATES.GRASS:
			tile_map.erase_cell(2, Vector2(x, y))

# generates initial display grid when game launched
# checks every tile and sets the cell in the tile map to match
func gen_display():
	gen_bg_water()
	# grass corners
	tile_map.set_cell(1, Vector2(0, 0), 0, Vector2i(0,0), 0)
	tile_map.set_cell(1, Vector2(0, size-1), 0, Vector2i(0,2), 0)
	tile_map.set_cell(1, Vector2(size-1, 0), 0, Vector2i(2,0), 0)
	tile_map.set_cell(1, Vector2(size-1, size-1), 0, Vector2i(2,2), 0)
	# grass sides
	for i in range(1,size-1):
		tile_map.set_cell(1, Vector2(0, i), 0, Vector2i(0,1), 0)
		tile_map.set_cell(1, Vector2(size-1, i), 0, Vector2i(2,1), 0)
		tile_map.set_cell(1, Vector2(i, 0), 0, Vector2i(1,0), 0)
		tile_map.set_cell(1, Vector2(i, size-1), 0, Vector2i(1,2), 0)
	# rest of grass insides
	for x in range(1,size-1):
		for y in range(1,size-1):
			tile_map.set_cell(1, Vector2(x, y), 0, Vector2i(0,5), 0)
	# other states
	for x in size:
		for y in size:
			match tiles.get_state(x,y):
				Grid.STATES.WATER:
					var x_tile: int
					var y_tile: int
					if x == 0 and y == 0:
						x_tile = 0
						y_tile = 2
					elif x == 0 and y == (size - 1):
						x_tile = 2
						y_tile = 2
					elif x == (size - 1) and y == 0:
						x_tile = 1
						y_tile = 2
					elif x == (size - 1) and y == (size - 1):
						x_tile = 3
						y_tile = 2
					elif x == 0:
						x_tile = 0
						y_tile = 1
					elif x == (size - 1):
						x_tile = 1
						y_tile = 1
					elif y == 0:
						x_tile = 3
						y_tile = 1
					elif y == (size - 1):
						x_tile = 2
						y_tile = 1
					else:
						x_tile = 0
						y_tile = 0
						
					tile_map.set_cell(1, Vector2(x, y), 1, Vector2i(x_tile,y_tile), 0)
				Grid.STATES.CROP:
					tile_map.set_cell(2, Vector2(x, y), 3, Vector2i(4,0), 0)
				Grid.STATES.ROCK:
					tile_map.set_cell(2, Vector2(x, y), 4, Vector2i(0,1), 0)

# generates the water around the farm
func gen_bg_water():
	var min: int = -50
	var max: int = min * -1
	var curr_tile: int = 0
	for y in range(min,max+1):
		curr_tile = 0
		for x in range(min,max+1):
			tile_map.set_cell(0, Vector2(x, y), 5, Vector2i(curr_tile,0), 0)
			if curr_tile == 3:
				curr_tile = 0
			else:
				curr_tile += 1

# function that centers the finish label that shows up when you beat the level
func center_finish_label():
	# get length and width of the panel
	var panel_len = finish_panel.size.x
	var panel_height = finish_panel.size.y
	# get length and width of the label
	var label_len = finish_label.size.x
	var label_height = finish_label.size.y
	# calculate where the position of the label (top left point) should be
	var label_x = int((panel_len - label_len) / 2)
	var label_y = int((panel_height - label_height) / 2)
	# set the position
	finish_label.set_position(Vector2(label_x, label_y - 15))
	
	# center the next button as well
	var btn_len = next_button.size.x
	var btn_height = next_button.size.y
	# calculate where the position of the button (left point) should be
	var btn_x = int((panel_len - btn_len) / 2)
	var btn_y = next_button.position.y
	# set the position
	next_button.set_position(Vector2(btn_x, btn_y))
	# set home and retry buttons to be in line with next button, and evenly spaced out
	var spacing: int = 85
	var retry_x = btn_x - spacing - btn_len 
	var home_x = btn_x + btn_len + spacing
	retry_button.set_position(Vector2(retry_x, btn_y))
	home_button.set_position(Vector2(home_x, btn_y))

# function that triggers whenever timer times out / ends.
# timer is currently set to 0.5s, and repeats constantly
# this function gets the co-ords of the next tile to update from the grid, and then updates it
# if there are no tiles to update, this function does nothing
func _on_timer_timeout():
	var out_str = output_q.pop_front()
	if out_str != null:
		# extract the x and y co-ordinates from the message. The co-ordinates are in the form (x, y)
		var pos = out_str.find("(")
		var comma_pos = out_str.find(",")
		var x_len = comma_pos - pos - 1
		var end_pos = out_str.find(")")
		var y_len = end_pos - comma_pos - 2
		var x = int(out_str.substr(pos+1,x_len))
		var y = int(out_str.substr(pos+4,y_len))
		# check what the message begins with, and update the correct tile with correct update, and play sfx sound
		if out_str.begins_with("ERROR"):
			error_audio.play()
			num_erros += 1
			output.append_text(out_str)
			print(out_str)
			tile_map.set_cell(3, Vector2(x, y), 0, Vector2i(12,3), 0)
			await error_audio.finished
		elif out_str.begins_with("Crop planted"):
			plant_audio.play()
			output.append_text(out_str)
			print(out_str)
			update_display(x, y)
			await plant_audio.finished
		elif out_str.begins_with("Crop harvested"):
			harvest_audio.play()
			output.append_text(out_str)
			print(out_str)
			update_display(x, y)
			num_crops_harvested += 1
			crop_counter.text = str(num_crops_harvested) + "/" + str(tiles.get_crops_required())
			crop_icon.global_position.x = crop_counter.position.x - 5 - (crop_icon.scale.x*16)
			await harvest_audio.finished
		elif out_str.begins_with("Rock"):
			break_rock_audio.play()
			update_display(x, y)
			output.append_text(out_str)
			print(out_str)
			num_rocks_broken += 1
			await break_rock_audio.finished
			
		else:
			error_audio.play()
			output.append_text(out_str)
			print(out_str)
			await error_audio.finished
			
	else: # check if level has been cleared, and that all grid updates have been completed
		var rocks_rem = tiles.get_rocks_needed() - num_rocks_broken
		if (rocks_rem == 0) and (num_crops_harvested >= tiles.get_crops_required()):
			is_level_cleared = true
			end_level()
		else:
			run_button.disabled = false # only enable button when all updates of previous code are done and the level is not cleared
	
	#print(is_level_cleared)
	#print(tiles.is_completed(num_crops_harvested))
	#is_level_cleared = tiles.is_completed(num_crops_harvested)
	timer.start()

# ends the current level and displays the finish panel
func end_level():
	run_button.disabled = true # disable run button
	# stop the timers
	timer.stop()
	count_up_timer.stop()
	# calculate final score
	var score = total_time + (num_times_button_pressed * 10) + (num_erros * 50) + (num_times_help_pressed * 20) + (num_times_func_typed * 5 if num_times_func_typed > 10 else 0)
	# display final score
	finish_label.text = "Level " + str(level) + " Cleared! Well done!\n\nFinal Score: " + str(score) + "\n\n(Lower Is Better!)"
	center_finish_label()
	finish_panel.visible = true
	if level == 5:
		next_button.disabled = true
	else:
		next_button.disabled = false
	print("LEVEL CLEARED!") #for debug
	
	_save_user_score(score, level)

# saves the user score if they set a new best score for that level
func _save_user_score(score: int, level: int):
	
	var leaderboard_name = "main" if  level == 1 else "level" + str(level)
	SilentWolf.Scores.save_score(Global.current_player.username, -1 * score, leaderboard_name)
	Global.current_player.update_score(score, level)
	
# this function increments the timer counter and displays the time on screen in hours:mins:secs
func _on_count_up_timer_timeout():
	total_time += 1 # inc time
	var mins = int(total_time / 60) # calc minutes
	var secs = total_time - (mins * 60) # remaining seconds
	var hours = int(mins / 60) # calc hours
	mins = mins - (hours * 60) # remaining minutes
	# update label to show current time
	timer_label.text = 'Time: %02d:%02d:%02d' %[hours, mins, secs]
	
# adds the objectives to the panel
func update_objectives(level_number):
	objectives_label.text = "Level " + str(level_number) + " Objectives:\n\n" + "Plant crops along the river\nClear all rocks\nPlant crops along the river\nHarvest " +  str(tiles.crops_required) +" crops"

# triggers when user presses the reset (renamed to clear) button. Clears errors and output window
func _on_btn_reset_pressed():
	output.clear()
	clear_error_highlights()
	run_button.disabled = false

# show objectives when user hovers over the tick icon
func _on_texture_button_mouse_entered():
	objectives_panel.visible = true

# hide objectives when user no longer hovering over the tick icon
func _on_texture_button_mouse_exited():
	objectives_panel.visible = false

# gets the grid size of the grid (length)
func get_grid_size(level_number):
	return 8 + (level_number - 1) * 3  # Same as in the level generator

# ensures whole grid fits on screen
func scale_grid(new_grid_size):
	# Calculate the new scale factor
	var scale_factor = float(BASE_GRID_SIZE) / float(new_grid_size)
	var new_scale = BASE_SCALE * scale_factor
	
	# Apply the new scale to the TileMap
	tile_map.scale = Vector2(new_scale, new_scale)
	
	# Calculate the new grid size in pixels
	var new_pixel_size = new_grid_size * BASE_TILE_SIZE * new_scale
	
	# Center the TileMap in the view
	#var viewport_size = get_viewport_rect().size
	#tile_map.position = (viewport_size - Vector2(new_pixel_size, new_pixel_size)) / 2
	

# what happens when user presses the retry button after completing a level. Restarts the same level
func _on_retry_button_pressed():
	load_level(level)
	reset()
	finish_panel.hide()

# goes to the next level
func _on_next_lvl_button_pressed():
	if level < 5:
		level += 1
	load_level(level)
	reset()
	finish_panel.hide()

# returns to home page when home button pressed
func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://scenes/home.tscn")

# opens settings menu
func _on_settings_button_pressed():
	center_settings_menu()
	settings_menu.show()
	timer.paused = true
	count_up_timer.paused = true

# function that checks if user presses a key
func _input(event):
	if event.is_action_pressed("ui_cancel"): # default keybid in Godot to escape. This will trigger when escape key is pressed
		center_settings_menu()
		settings_menu.visible = !settings_menu.visible # toggle settings visibilty
		

# checks if user enters x or y co-ords that is out of bounds of grid
func _out_of_bounds_handler(x: int, y: int):
	var outOfBound: bool = (x < 0 or x >= size) or (y < 0 or y >= size)
	if outOfBound:
		output_q.push_back("ERROR: Specified grid position (" + str(x) + ", " + str(y) + ") out of bounds\n")
		
	return outOfBound

# ensure the settings menu is in center of screen
func center_settings_menu():
	settings_menu.global_position = $Camera2D.position

# pause or start timer depending on if menu is visible or not
func _on_menu_bg_visibility_changed():
	if settings_menu.visible:
		timer.paused = true
		count_up_timer.paused = true
	else:
		timer.paused = false
		count_up_timer.paused = false
		

# shows file explorer to save the user code
func _on_save_button_pressed():
	fd_save.visible = true

# shows file explorer to load previously saved code
func _on_load_button_pressed():
	fd_load.visible = true

#  saves the file
func _on_dialog_save_file_selected(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(code_edit.text)
	file.close()

# loads the file in to the code editor
func _on_dialog_load_file_selected(path):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		code_edit.text = file.get_as_text()
		file.close()

# checks if the grid has a rock anywhere on it
func has_a_rock():
	for x in size:
		for y in size:
			if is_rock(x, y):
				return true
	return false

# checks if the grid has a crop anywhere on it
func has_a_crop():
	for x in size:
		for y in size:
			if harvestable(x, y):
				return true
	return false

# function to handle the signals emitted at different stages of the dialogue, and update the grid accordingly
func handle_dialogue(arg: String):
	print(arg)
	match arg:
		"finished":
			dialogue_box.hide()
			help_timer.start()

# plays the dialogue using the name supplied
func play_dialogue(name: String):
	dialogue_box.show()
	Dialogic.start(name)

# dynamically checks what type of help the player needs, and then highlights all the grid locations player needs to progress 
# and plays the associated dialogue which gives hints and tips.
# if there's rocks on the grid, the highlight them all, else if there's crops on the grid, highlight them all, 
# else highlight all spots crops can be planted on 
func _on_help_button_pressed():
	if has_a_rock():
		for x in size:
			for y in size:
				if is_rock(x, y):
					tile_map.set_cell(3, Vector2(x, y), 0, Vector2i(11,4), 0)
		play_dialogue("help_rock")
	elif has_a_crop():
		for x in size:
			for y in size:
				if harvestable(x, y):
					tile_map.set_cell(3, Vector2(x, y), 0, Vector2i(11,4), 0)
		play_dialogue("help_harvest")
	else:
		for x in size:
			for y in size:
				if is_plantable(x, y):
					tile_map.set_cell(3, Vector2(x, y), 0, Vector2i(11,4), 0)
		play_dialogue("help_plant")

# clear the yellow highlights after the timer ends (after 3s)
func _on_help_timer_timeout():
	clear_error_highlights()
