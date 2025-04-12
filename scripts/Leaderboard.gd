@tool
extends Node2D

"""
Script to handle the leaderboard scene
"""

const ScoreItem = preload("res://scenes/ScoreItem.tscn")
const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")	# Logger provided by the api 

@onready var item_list = $Board/ItemList
var list_index = 0	# keeps track of the position displayed on the leaderboard
var max_scores = 20

# By default loads and selects leaderboard for level 1
func _ready():
	load_leaderboard("main")
	item_list.select(0)
	

# Function to retrieve the leaderboard scores ofa particular level 
func load_leaderboard(leaderboard: String):
	print("SilentWolf.Scores.leaderboards: " + str(SilentWolf.Scores.leaderboards))
	print("SilentWolf.Scores.ldboard_config: " + str(SilentWolf.Scores.ldboard_config))
	var scores = []
	if leaderboard in SilentWolf.Scores.leaderboards:
		scores = SilentWolf.Scores.leaderboards[leaderboard]
	
	if len(scores) > 0: 
		render_board(scores)
	else:
		# use a signal to notify when the high scores have been returned, and show a "loading" animation until it's the case...
		add_loading_scores_message()
		var sw_result = await SilentWolf.Scores.get_scores(max_scores, leaderboard).sw_get_scores_complete
		scores = sw_result["scores"]
		hide_message()
		render_board(scores)


# Function to display the scores of the retrieved leaderboard to the UI
func render_board(scores: Array) -> void:
	if scores.is_empty():
		add_no_scores_message()
	else:
		hide_message()
		for i in range(len(scores)):
			var score = scores[i]
			add_item(score.player_name, str(-1 * int(score.score)))
		
			
# Function to add a score tab of a player to display it to the leaderboard UI
func add_item(player_name: String, score_value: String) -> void:
	var item = ScoreItem.instantiate()
	list_index += 1
	item.get_node("PlayerName").text = str(list_index) + str(". ") + player_name
	item.get_node("Score").text = score_value
	item.offset_top = list_index * 100
	$"Board/HighScores/ScrollContainer/ScoreItemContainer".add_child(item)


# Function to show message when no scores are available
func add_no_scores_message() -> void:
	var item = $"Board/MessageContainer/TextMessage"
	item.text = "No scores yet!"
	$"Board/MessageContainer".show()
	item.offset_top = 135


# Function to display a loading mechanism while retrieving scores
func add_loading_scores_message() -> void:
	var item = $"Board/MessageContainer/TextMessage"
	item.text = "Loading scores..."
	$"Board/MessageContainer".show()
	item.offset_top = 135


func hide_message() -> void:
	$"Board/MessageContainer".hide()


# Function to clear the leaderboard display
func clear_leaderboard() -> void:
	var score_item_container = $"Board/HighScores/ScrollContainer/ScoreItemContainer"
	if score_item_container.get_child_count() > 0:
		var children = score_item_container.get_children()
		for c in children:
			score_item_container.remove_child(c)
			c.queue_free()

# Returns to home screen
func _on_CloseButton_pressed() -> void:
	var scene_name = SilentWolf.scores_config.open_scene_on_close
	SWLogger.info("Closing SilentWolf leaderboard, switching to scene: " + str(scene_name))
	get_tree().change_scene_to_file(scene_name)


# Function to handle the level selection tab and displaying the correct scoreboard
func _on_item_list_item_selected(index):
	var current_ld: String;
	match index:
		0:
			current_ld = "main"
		1:
			current_ld = "level2"
		2:
			current_ld = "level3"
		3:
			current_ld = "level4"
		4:
			current_ld = "level5"
		
	clear_leaderboard()
	list_index = 0
	load_leaderboard(current_ld)
