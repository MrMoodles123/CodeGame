extends Node

"""
Global script to do all initialization required for the game and store values needed throughout the game
"""

enum GAME_STATE {MENU, TUTORIAL, CHALLENGE}

const FILEPATH = "res://config.cfg"		# name to the user config file
var current_player: Player				# Global variable to allow access to information about the current player throughout the game
var game_state: GAME_STATE				# stores the current game state
var config_file: ConfigFile				# used to manipulate user config file

# Starts initialisation when the game is executed
func _ready():
	config_file = ConfigFile.new()
	_silentWolf_config()
	_get_user_profile()
	_check_user_scripts_dir()
	print()
	
  
# configuration for SilentWolf api usage
func _silentWolf_config() -> void:
	SilentWolf.configure({
	"api_key": "YcWoEdzUi86EnUKpIAp64pfg0v3TqLOaD7vpwmze",
	"game_id": "CodeGame",
	"log_level": 1
  	})
	SilentWolf.configure_scores({
		"open_scene_on_close": "res://scenes/home.tscn"
  	})
	

# Retrieve the username and game status of current user from config file
func _get_user_profile():
	
	var file_status = config_file.load(FILEPATH)
	
	# checks if config file exists to retrieve the info and progress of current player
	if file_status == OK:
		var username: String = config_file.get_value("profile", "username")
		var tutorial_level: int = config_file.get_value("profile", "tutorial")
		var challenge_level: int = config_file.get_value("profile", "challenge")
		var best_scores: Array = config_file.get_value("profile", "scores")
		var settings: Array = config_file.get_value("profile", "settings")
		
		current_player = Player.new(username.to_upper(), tutorial_level, challenge_level)
		current_player.best_scores = best_scores
		current_player.settings = settings
		
	else:	# creates guest account
		current_player = Player.new("GUEST", 1, 0)
		updatePlayerData()
		

# Updates the user information and progress in the user config file throughout the game
func updatePlayerData() -> void:
	# Avoids updating progress of guest accounts
	if current_player.username != "GUEST":
		config_file.set_value("profile", "username", current_player.username)
		config_file.set_value("profile", "tutorial", current_player.tutorial_level)
		config_file.set_value("profile", "challenge", current_player.challenge_level)
		config_file.set_value("profile", "scores", current_player.best_scores)
		config_file.set_value("profile", "settings", current_player.settings)
	else:
		config_file.set_value("profile", "username", "GUEST")
		config_file.set_value("profile", "tutorial", current_player.tutorial_level)
		config_file.set_value("profile", "challenge", current_player.challenge_level)
		config_file.set_value("profile", "scores", [100000,100000,100000,100000,100000])
		config_file.set_value("profile", "settings", current_player.settings)
	var error = config_file.save(FILEPATH)
	if error == OK:
		print("Config file created successfully.")
	else:
		print("Failed to create config file: ", error)
	

# checks directory for saved user scripts otherwise creates one to store them
func _check_user_scripts_dir():
	var dir = DirAccess.open("res://user_scripts/")
	if dir == null:  # If the directory doesn't exist
		dir = DirAccess.open("res://")
		if dir != null:
			dir.make_dir("user_scripts")  # Create the directory
			print("Directory 'user_scripts' created successfully.")
		else:
			print("Failed to access the user directory.")
	else:
		print("Directory 'user_scripts' already exists.")
