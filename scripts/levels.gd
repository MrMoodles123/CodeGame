class_name Levels extends Control

"""
Script to handle the level selection screen for both tutorials and challenges
"""

#@onready var levels_container : HBoxContainer = $ScrollContainer/Level_container
const button = preload("res://scenes/button_design.tscn")
var main = preload("res://scenes/main.tscn")

@export var max_levels: int = 1
static var challenge_level: int = 1
static var tutorial_level: int = 1

func _ready():
	pass

# Function that is executed when the user switches to the level scene
func _enter_tree():
	# configure values to display the tutorial levels
	if Global.game_state == Global.GAME_STATE.TUTORIAL:
		max_levels = 10
		_set_levels(Global.current_player.tutorial_level)
		
	# configure values to display the challenge levels	
	elif Global.game_state == Global.GAME_STATE.CHALLENGE:
		max_levels = 5
		_set_levels(Global.current_player.challenge_level)
	

# Function to generate level number buttons based on game state and user progress
func _set_levels(completed_levels: int):
	
	# Creates buttons for level selection based on max levels
	for i in range(max_levels):
		# Creates button instances for the UI to be displayed
		var instance = button.instantiate()
		instance.text = str(i + 1)
		instance.pressed.connect(self._on_level_pressed.bind(i + 1))
		
		# condtion used to disable levels the user have not unlocked yet
		if i >= completed_levels:
			instance.disabled = true
			
		$ScrollContainer/Level_container.add_child(instance)
		

# Functionality for back button
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/home.tscn")


# Function to handle scene transition when a level button is pressed
func _on_level_pressed(level_number: int):
	# generates the specified tutorial level
	if Global.game_state == Global.GAME_STATE.TUTORIAL:
		tutorial_level = level_number
		get_tree().change_scene_to_file("res://scenes/Tutorial.tscn")
		
	# generates the specified challenge level		
	elif Global.game_state == Global.GAME_STATE.CHALLENGE:
		challenge_level = level_number
		#var game = Game.new()
		#game.request_ready()
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	
