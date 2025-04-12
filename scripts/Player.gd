extends Node

"""
Class to represent a plyer
"""
class_name Player

# attributes
var username: String
var tutorial_level: int
var challenge_level: int
var best_scores: Array = []
var settings: Array = []		# Used to store the preferred user settings

# constructor
func _init(name: String, tut_level : int, challenge_level: int):
	self.username = name
	self.tutorial_level = tut_level
	self.challenge_level = challenge_level
	for i in range(5):
		best_scores.append(100000)
	set_default_settings()
	#Global.updatePlayerData();
	
# sets the default game settings for the user
func set_default_settings():
	settings.append(0.5)
	settings.append(1)
	settings.append(0)
	settings.append(0)
	settings.append(0)

# Function to increase the user tutorial progress and store it
func increment_tutorial_level() -> void:
	self.tutorial_level += 1
	if tutorial_level > 10:
		increment_challenge_level()
	Global.updatePlayerData();

# Function to increase the user challenge progress and store it
func increment_challenge_level() -> void:
	self.challenge_level += 1
	Global.updatePlayerData();
	
# Function to update the tutorial progress in game
func update_tut_lvl(new_level: int) -> void:
	
	# checks whether provided level was cleared before	
	if tutorial_level == new_level:
		increment_tutorial_level()

# Function to update the challenge level score and progress
func update_score(score: int, level: int) -> void:
	
	# checks whether provided level was cleared before
	if level == challenge_level:
		increment_challenge_level()
		
	# updates best score if it is better than the currently stored score for the level
	if best_scores[level-1] > score :
		best_scores[level-1] = score
		Global.updatePlayerData()
