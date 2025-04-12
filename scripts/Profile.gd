extends Panel

"""
Script to handle the display of user profile panel accessed from the home screen
"""

@onready var scores_panel :  = $scores

# Initialises the information to be displayed on the profile panel and makes it hidden before button press
func _ready():
	scores_panel.hide()
	# displays the username, tutorial status and main game status of user
	$username.text = Global.current_player.username
	if Global.current_player.tutorial_level == 11:
		$tutorial.text = "DONE"
	else:
		$tutorial.text = str(Global.current_player.tutorial_level)
		
	$challenge.text = str(Global.current_player.challenge_level)
	

# Function to handle action on close button
func _on_close_button_pressed():
	self.visible = false


# Function to extract the stored best scores of the user and display them on mouse enter
func _on_scores_display_mouse_entered():
	var display : String = "{\n"
	for i in range(5):
		var score = Global.current_player.best_scores[i]
		
		# checks if the stored score is not the default score so it can be displayed
		if score < 100000:
			display += "\tLevel " + str(i + 1) + ":   " + str(score) + "\n"
		else:
			display += "\tLevel " + str(i + 1) + ": N/A\n"
			
	scores_panel.show()
	$scores/Label.text = display + "\n}"


# function to hide panel on mouse not hovering on the score button
func _on_scores_display_mouse_exited():
	scores_panel.hide()
