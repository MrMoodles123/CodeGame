class_name Tutorial extends Node2D

@onready var  dialogue_box = $DialogueBoxPanel
@onready var tile_map = $TileMap
@onready var arrow = $Arrow
@onready var code_edit = $CodeEdit # editor that the user types in
@onready var placeholder_code_edit = $PlaceholderCodeEdit
@onready var run_button = $RunButton
@onready var crop_icon = $CropIcon
@onready var crop_counter_label = $CropIcon/CropCountLabel
@onready var crop_count_timer = $CropIcon/CropItemTimer
@onready var settings_menu = $MenuBG
@onready var cam = $Camera2D
@onready var sfx_player = $SFXPlayer

var test: bool = true

var curr_grid_size: int = 3 # current size of grid, will change as tutorial progresses
var curr_lvl: int = 1 # current level of the tutorial
var map_scale: int = 3 # scale of tiles
var num_crops_harvested: int = 0
var tiles # the grid
var output_q = [] # strings to be outputted to outputlabel
var validate_mode: bool = false
const SC = "extends Tutorial\nfunc update_grid(new_grid): tiles = new_grid\nfunc return_grid(): return tiles\nfunc get_out_q(): return output_q\nfunc set_crop_count(val): num_crops_harvested = val\nfunc get_crop_count(): return num_crops_harvested\nfunc execute():\n" 
const SC2 = "extends Tutorial\nfunc update_grid(new_grid): tiles = new_grid\nfunc return_grid(): return tiles\nfunc get_out_q(): return output_q\nfunc set_crop_count(val): num_crops_harvested = val\nfunc get_crop_count(): return num_crops_harvested\n" 
# error, harv, plant, rock
var audios = [preload("res://Audio/SFX/Error - Sound Effect.mp3"),preload("res://Audio/SFX/HarvestSFX.mp3"),preload("res://Audio/SFX/PlantSFX.mp3"),preload("res://Audio/SFX/RockSFX.mp3")]
var dbs = [-10,-10,-10,-20]
var current_sfx: int = 2

func _ready():
	curr_lvl = Levels.tutorial_level
	code_edit.size = Vector2(468/code_edit.scale.x,605/code_edit.scale.y)
	placeholder_code_edit.scale = code_edit.scale
	placeholder_code_edit.size = code_edit.size
	for keyword in ["var", "if", "else", "elif", "for", "while", "in", "break", "pass", "continue", "func"]:
		code_edit.syntax_highlighter.add_keyword_color(keyword, Color("d8b1e0"))
	arrow.hide()
	disable_components()
	enable_components()
	show_crop_counter_and_hide()
	tile_map.scale = Vector2i(map_scale, map_scale)
	Dialogic.signal_event.connect(handle_dialogue)
	
	if curr_lvl < 6:
		curr_grid_size = 3
	else:
		curr_grid_size = 5
	tiles = TutorialGrid.new(curr_grid_size, curr_lvl)
	gen_display()
	gen_bg_water()
	
	# Start the 1st tutorial dialogue
	dialogue_box.show()
	start_next_dialogue()

# plays the sound effect when updating tiles
func play_sfx():
	sfx_player.volume_db = dbs[current_sfx]
	sfx_player.stream = audios[current_sfx]
	sfx_player.play()

# sets he sound effect to play
func set_sfx(index: int):
	current_sfx = index

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

# function to position the tutorial arrow to point to where it needs to 
func position_arrow(pos):
	arrow.hide()
	var x
	var y
	var arrow_scale
	var rotation_deg
	match pos:
		"farm":
			x = 24*3
			y = -5
			arrow_scale = 0.5
			rotation_deg = 0
		"run_button":
			x = run_button.position.x + (run_button.size.x / 2)
			y = run_button.position.y + run_button.size.y + 20
			arrow_scale = 0.3
			rotation_deg = 180
		"code_editor":
			x = code_edit.position.x + code_edit.size.x + 25
			y = 50
			arrow_scale = 0.5
			rotation_deg = 90
		"crop_count":
			x = crop_icon.position.x - 50
			y = crop_counter_label.position.y + (crop_counter_label.size.y/2)
			y = crop_counter_label.global_position.y + (crop_counter_label.size.y/2)
			arrow_scale = 0.3
			rotation_deg = 270
	
	arrow.set_position(Vector2i(x,y))
	arrow.set_rotation_degrees(rotation_deg)
	arrow.set_scale(Vector2(arrow_scale,arrow_scale))
	arrow.show()

# generates initial display grid when game launched checks every tile and sets the cell in the tile map to match
func gen_display():
	# grass corners
	tile_map.set_cell(1, Vector2(0, 0), 0, Vector2i(0,0), 0)
	tile_map.set_cell(1, Vector2(0, curr_grid_size-1), 0, Vector2i(0,2), 0)
	tile_map.set_cell(1, Vector2(curr_grid_size-1, 0), 0, Vector2i(2,0), 0)
	tile_map.set_cell(1, Vector2(curr_grid_size-1, curr_grid_size-1), 0, Vector2i(2,2), 0)
	# grass sides
	for i in range(1,curr_grid_size-1):
		tile_map.set_cell(1, Vector2(0, i), 0, Vector2i(0,1), 0)
		tile_map.set_cell(1, Vector2(curr_grid_size-1, i), 0, Vector2i(2,1), 0)
		tile_map.set_cell(1, Vector2(i, 0), 0, Vector2i(1,0), 0)
		tile_map.set_cell(1, Vector2(i, curr_grid_size-1), 0, Vector2i(1,2), 0)
	# rest of grass insides
	for x in range(1,curr_grid_size-1):
		for y in range(1,curr_grid_size-1):
			tile_map.set_cell(1, Vector2(x, y), 0, Vector2i(0,5), 0)
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
						x_tile = 3
						y_tile = 1
					elif y == (curr_grid_size - 1):
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

# this function starts the next diaglogue sequence
func start_next_dialogue():
	dialogue_box.show()
	if curr_lvl == 1:
		Dialogic.start("TutorialTimeline")
	elif curr_lvl > 10:
		Dialogic.start("final")
	else:
		var string = "tut" + str(curr_lvl)
		Dialogic.start(string)

# function to handle the signals emitted at different stages of the dialogue, and update the grid accordingly
func handle_dialogue(arg: String):
	print(arg)
	match arg:
		"ErrorDone":
			position_arrow("run_button")
			enable_components()
			dialogue_box.hide()
			validate_mode = true
		"whole_farm":
			whole_farm()
		"Tile0":
			#clear_highlights()
			highlight_tile(0,0)
		"Tile1":
			clear_highlights()
			highlight_tile(0,1)
		"Tile2":
			clear_highlights()
			highlight_tile(1,0)
		"Clear":
			clear_highlights()
			enable_components()
			code_edit.clear()
			code_edit.placeholder_text = ""
			placeholder_code_edit.text = ""
			disable_components()
			arrow.hide()
		"CodeEdit":
			position_arrow("code_editor")
		"Crops":
			highlight_tile(1,0)
			highlight_tile(1,2)
			highlight_tile(0,1)
			highlight_tile(2,1)
		"Top_Crop":
			clear_highlights()
			highlight_tile(1,0)
			enable_components()
			code_edit.placeholder_text = "plant_crop(1,0)"
			placeholder_code_edit.text = code_edit.placeholder_text
			if test:
				code_edit.text = code_edit.placeholder_text
			else:
				code_edit.text = ""
			disable_components()
		"Tut1Done":
			enable_components()
			dialogue_box.hide()
			position_arrow("run_button")
			validate_mode = true
		"harvest":
			set_sfx(1)
			highlight_tile(1,0)
			enable_components()
			code_edit.clear()
			code_edit.placeholder_text = "harvest(1,0)"
			placeholder_code_edit.text = code_edit.placeholder_text
			if test:
				code_edit.text = code_edit.placeholder_text
			else:
				code_edit.text = ""
			disable_components()
		"CropCount":
			position_arrow("crop_count")
		"GenRock":
			arrow.hide()
			set_sfx(3)
			crop_count_timer.start()
			tiles.place_tut_rock(0,1)
		"BreakRock":
			highlight_tile(0,1)
			enable_components()
			code_edit.clear()
			code_edit.placeholder_text = "break_rock(0,1)"
			placeholder_code_edit.text = code_edit.placeholder_text
			if test:
				code_edit.text = code_edit.placeholder_text
			else:
				code_edit.text = ""
			disable_components()
		"plant_crop":
			enable_components()
			code_edit.text = "if (!is_plantable(x, y)):\n\treturn false\nupdate_tile(x, y, STATES.CROP)\nqueue_x.push_back(x)\nqueue_y.push_back(y)\nreturn true"
			disable_components()
		"if2":
			enable_components()
			code_edit.text = "if is_plantable(1,0):\n\tplant_crop(1,0)"
			disable_components()
		"if-else":
			enable_components()
			code_edit.text = "if is_plantable(1,0):\n\tplant_crop(1,0)\nelse:\n\tbreak_rock(1,0)"
			disable_components()
		"if-chain":
			enable_components()
			code_edit.text = "if is_plantable(1,0):\n\tplant_crop(1,0)\nelif is_rock(1,0):\n\tbreak_rock(1,0)\nelif harvestable(1,0):\n\tharvest(1,0)"
			disable_components()
		"Tut4Done":
			Global.current_player.update_tut_lvl(curr_lvl)
			curr_lvl += 1
			disable_components()
			start_next_dialogue()
		"vars":
			set_sfx(2)
			enable_components()
			code_edit.placeholder_text = "var x = 1\nvar y = 0\nif is_plantable(x,y):\n\tplant_crop(x,y)"
			placeholder_code_edit.text = code_edit.placeholder_text
			if test:
				code_edit.text = code_edit.placeholder_text
			else:
				code_edit.text = ""
			disable_components()
		"start6":
			tiles = TutorialGrid.new(5,6)
			tile_map.clear_layer(1)
			tile_map.clear_layer(2)
			curr_grid_size = 5
			gen_display()
		"loop":
			enable_components()
			code_edit.placeholder_text = "for x in range(0,5):\n\tplant_crop(x,1)"
			placeholder_code_edit.text = code_edit.placeholder_text
			if test:
				code_edit.text = code_edit.placeholder_text
			else:
				code_edit.text = ""
			disable_components()
		"Tut7Crop":
			set_sfx(1)
			for x in 5:
				if tiles.get_state(x,1) != Grid.STATES.CROP:
					tiles.update_tile(x, 1, Grid.STATES.CROP)
					update_display(x,1)
		"harvest_loop":
			enable_components()
			code_edit.placeholder_text = "for x in range(0,5):\n\tharvest(x,1)"
			placeholder_code_edit.text = code_edit.placeholder_text
			if test:
				code_edit.text = code_edit.placeholder_text
			else:
				code_edit.text = ""
			disable_components()
		"nested_loop":
			enable_components()
			code_edit.text = "for y in range(0,5):\n\tfor x in range(0,5):\n\tharvest(x,y)"
			disable_components()
		"rocks":
			set_sfx(3)
			tiles.gen_tut_rocks(5)
			gen_display()
		"break_rocks":
			enable_components()
			code_edit.placeholder_text = "for y in range(0,5):\n\tfor x in range(0,5):\n\t\tif is_rock(x,y):\n\t\t\tbreak_rock(x,y)"
			placeholder_code_edit.text = code_edit.placeholder_text
			if test:
				code_edit.text = code_edit.placeholder_text
			else:
				code_edit.text = ""
			disable_components()
		"array":
			enable_components()
			tiles.set_crop_location(4)
			code_edit.text = "var array = []"
			disable_components()
		"array_set":
			enable_components()
			code_edit.text = "var array = []\narray.append(10)"
			disable_components()
		"array_get":
			set_sfx(2)
			enable_components()
			code_edit.text = "var array = []\narray.append(10)\nvar i = array[0]"
			disable_components()
		"full_array":
			enable_components()
			code_edit.placeholder_text = "var array_x = []\nvar array_y = []\nfor y in range(0,5):\n\tfor x in range(0,5):\n\t\tif is_plantable(x,y):\n\t\t\tarray_x.append(x)\n\t\t\tarray_y.append(y)\nfor i in range(0,array_x.size()):\n\tplant_crop(array_x[i],array_y[i])"
			placeholder_code_edit.text = code_edit.placeholder_text
			if test:
				code_edit.text = code_edit.placeholder_text
			else:
				code_edit.text = ""
			disable_components()
		"Tut10Crop":
			for x in 5:
				if tiles.get_state(x,1) != Grid.STATES.CROP:
					tiles.update_tile(x, 1, Grid.STATES.CROP)
					update_display(x,1)
				if tiles.get_state(x,3) != Grid.STATES.CROP:
					tiles.update_tile(x, 3, Grid.STATES.CROP)
					update_display(x,3)
		"func":
			enable_components()
			code_edit.text = "func execute():"
			disable_components()
		"exec_eg":
			enable_components()
			code_edit.text = "func execute():\n\tfor x in range(0,5):\n\t\tharvest(x,1)"
			disable_components()
		"plant_func":
			set_sfx(1)
			enable_components()
			code_edit.text = "func execute():\n\tfor x in range(0,5):\n\t\tharvest(x,1)\nfunc harvest_row(y):\n\tfor x in range(0,5):\n\t\tharvest(x,y)"
			disable_components()
		"calling":
			enable_components()
			code_edit.placeholder_text = "func execute():\n\tharvest_row(1)\n\tharvest_row(3)\nfunc harvest_row(y):\n\tfor x in range(0,5):\n\t\tharvest(x,y)"
			placeholder_code_edit.text = code_edit.placeholder_text
			if test:
				code_edit.text = code_edit.placeholder_text
			else:
				code_edit.text = ""
			disable_components()
		"Done":
			clear_highlights()
			enable_components()
			dialogue_box.hide()
			position_arrow("run_button")
			validate_mode = true
		"tutorial_finished":
			clear_highlights()
			disable_components()
			dialogue_box.hide()
			arrow.hide()
			Global.current_player.update_tut_lvl(curr_lvl+1)
			get_tree().change_scene_to_file("res://scenes/home.tscn")
		"Tut2Crop":
			if tiles.get_state(1,0) != Grid.STATES.CROP:
				tiles.update_tile(1, 0, Grid.STATES.CROP)
				update_display(1,0)

# function to highlight the farm
func whole_farm():
	for x in curr_grid_size:
		for y in curr_grid_size:
			tile_map.set_cell(3, Vector2(x, y), 0, Vector2i(11,2), 0)
	position_arrow("farm")

# highlights a specific tile
func highlight_tile(x, y):
	tile_map.set_cell(3, Vector2(x, y), 0, Vector2i(11,4), 0)

# clears all highlights
func clear_highlights():
	tile_map.clear_layer(3)
	
# function that user calls to plant a crop on a given co-ord
func plant_crop(x, y):
	var planted = tiles.plant_crop(x, y)
	if planted:
		output_q.push_back("Crop planted successfully at (" + str(x) + ", " + str(y) + ")\n")
	else:
		output_q.push_back("ERROR: Crop could not be planted at (" + str(x) + ", " + str(y) + ")\n")
	print(planted)
	tiles.print_grid()

# function that user calls to harvest crop on a given co-ord
func harvest(x, y):
	var harvested = tiles.harvest(x,y)
	if harvested:
		output_q.push_back("Crop harvested successfully at (" + str(x) + ", " + str(y) + ")\n")
		num_crops_harvested += 1
		#show_crop_counter()
	else:
		output_q.push_back("ERROR: No crop to harvest at (" + str(x) + ", " + str(y) + ")\n")
	print(harvested)
	tiles.print_grid()

# function that user calls to break a rock on a given co-ord
func break_rock(x, y):
	var broken = tiles.break_rock(x, y)
	if broken:
		output_q.push_back("Rock removed successfully at (" + str(x) + ", " + str(y) + ")\n")
	else:
		output_q.push_back("ERROR: No rock to remove at (" + str(x) + ", " + str(y) + ")\n")
	print(broken)
	tiles.print_grid()

# function that user calls to get the state of a tile, using the co-ords of the tile
func get_state(x, y):
	var state = tiles.get_state(x, y)
	return state

#  function that user calls to checks if a crop can be planted on the given co-ords
func is_plantable(x, y):
	return tiles.is_plantable(x, y)

#  function that user calls to checks if a crop can be harvested on the given co-ords
func harvestable(x, y):
	return (get_state(x, y) == Grid.STATES.CROP)

#  function that user calls to checks if a rock is on the given co-ords
func is_rock(x, y):
	return (get_state(x, y) == Grid.STATES.ROCK)

# updates the display of a given tile
func update_display(x, y):
	match tiles.get_state(x,y):
		Grid.STATES.CROP:
			tile_map.set_cell(2, Vector2(x, y), 3, Vector2i(4,0), 0)
			play_sfx()
		Grid.STATES.GRASS:
			tile_map.erase_cell(2, Vector2(x, y))
			play_sfx()
		Grid.STATES.ROCK:
			tile_map.set_cell(2, Vector2(x, y), 4, Vector2i(0,1), 0)

# checks if the tutorial level has been cleared
func validate_lvl_complete():
	match curr_lvl:
		1:
			return (get_state(1,0) == Grid.STATES.CROP)
		2:
			return (get_state(1,0) == Grid.STATES.GRASS)
		3:
			return (get_state(0,1) == Grid.STATES.GRASS)
		5:
			return (get_state(1,0) == Grid.STATES.CROP)
		6:
			return tiles.is_done()
		7:
			print(tiles.only_grass())
			return tiles.only_grass()
		8:
			return tiles.only_grass()
		9:
			return tiles.is_done()
		10:
			return tiles.only_grass()

# this function executes when user presses the "run" button
func _on_run_pressed():
	# make sure validate mode is enabled to stop user from pressing the button when not allowed to
	if validate_mode == false:
		return
	# make sure the text entered matches up with what they were supposed to type
	if code_edit.text.strip_edges() != code_edit.placeholder_text.strip_edges():
		disable_components()
		validate_mode = false
		dialogue_box.show()
		Dialogic.start("error")
		return
	# disable button so user cannot spam it
	run_button.disabled = true
	# create user script
	var user_script = GDScript.new()
	
	# checks for empty code editor
	if code_edit.text == "":
		output_q.push_back("No code entered\n")
		run_button.disabled = false
		return
	if curr_lvl < 10:
		# indents every code of line
		var lines = code_edit.text.split("\n")	# stores each line as an array element
		for i in range(lines.size()):
			lines[i] = "	" + lines[i]	# adds indentation

		user_script.source_code = SC + "\n".join(lines) # adds source code
	else:
		user_script.source_code = SC2 +  code_edit.text # adds source code

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
			num_crops_harvested = crop_count
			show_crop_counter()
	else:
		output_q.push_back("SYNTAX ERROR in Code \n");

# function that triggers whenever timer times out / ends.
# timer is currently set to 0.5s, and repeats constantly
# this function gets the co-ords of the next tile to update from the grid, and then updates it
# if there are no tiles to update, this function checks if the level has been completed and moves to next level
func _on_timer_timeout():
	var next_x = tiles.get_next_x()
	var next_y = tiles.get_next_y()
	if (next_x != null) and (next_y != null):
		update_display(next_x, next_y)
	elif (next_x == null) and (next_y == null): # only enable button when all updates of previous code are done and the level is not cleared
		run_button.disabled = false
		# check if level cleared
		if validate_lvl_complete() && validate_mode:
			Global.current_player.update_tut_lvl(curr_lvl)
			curr_lvl += 1
			validate_mode = false
			disable_components()
			start_next_dialogue()
		else:
			output_q.push_back("Level not cleared \n");

# hide crop counter after a certain time (3s)
func _on_crop_item_timer_timeout():
	crop_icon.hide()
	
# shows the number of crops harvested
func show_crop_counter():
	crop_counter_label.text = str(num_crops_harvested)
	crop_icon.show()
	#crop_count_timer.start()

# shows the number of crops harvested and starts timer to hide
func show_crop_counter_and_hide():
	crop_counter_label.text = str(num_crops_harvested)
	crop_icon.show()
	crop_count_timer.start()

# enables code editor and run button
func enable_components():
	code_edit.editable = true
	run_button.disabled = false
	
# disables code editor and run button
func disable_components():
	#code_edit.editable = false
	run_button.set_disabled(true)
	
# makes sure settings menu is centerd
func center_settings_menu():
	settings_menu.global_position = cam.position

# function that checks if user presses a key
func _input(event):
	if event.is_action_pressed("ui_cancel"): # default keybid in Godot to escape. This will trigger when escape key is pressed
		if dialogue_box.visible == false:
			center_settings_menu()
			settings_menu.visible = !settings_menu.visible # toggle settings visibilty

# opens settigs menu
func _on_settings_button_pressed():
	center_settings_menu()
	settings_menu.show()

# returns to home screen
func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://scenes/home.tscn")
