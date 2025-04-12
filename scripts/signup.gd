@tool
extends Panel

"""
Script used to handle new user sign up
"""

@onready var _response_label: Label = $form_panel/response	# user message label in the UI

# Hides the text edits when panel is shown initially
func _ready():
	$form_panel.hide() 


# Function to handle the panel visibility on button Close profile pressed
func _on_close_pressed():
	self.visible = false

# Function to show the text edits for the user signup information
func _on_signup_pressed():
	
	$default_panel.hide()
	$form_panel.show()
	

# Function to handle the information of the new user signing up
func _on_register_pressed():
	# Retrieve the user inputs from text edits
	var username: String = ($form_panel/username.text).to_upper()
	var password: String = $form_panel/password.text
	
	# Validation for username
	if username == "":
		_response_label.text = "Username can't be empty"
		return
	
	if username.strip_edges() == "GUEST":
		_response_label.text = "Nice try :)\nInvalid username"
		return
	

	# Verification for exisiting username retrieved by means of api call
	var sw_result = await SilentWolf.Players.get_player_data(username).sw_get_player_data_complete
	
	# Checks if user already exist by means of checking available user data
	if sw_result.player_data.size() > 0:
		_response_label.text = "Username already exists"
		return
			
	# Validation for password
	if password.length() < 8:
		_response_label.text = "*** Password is too short"
		return
	
	# Saves the new user information with username and encrypted password
	SilentWolf.Players.save_player_data(username, {"password" : _XOR_encryption(password).uri_encode()})
	
	# Feedback for successful sign up
	_response_label.text = "User registered successfully"
	$form_panel/Register.disabled = true
	
	# Updates the information of the new user throughout the game
	Global.current_player.username = username
	Global.updatePlayerData()
		
		
# Function to encrypt a string by means of a key value
func _XOR_encryption(text: String) -> String:
	var key: String = "sEPteMBERtWenty24"
	var key_size: int = key.length()
	var result: String
	
	for i in range(text.length()):
		result += String.chr(text.unicode_at(i) ^ key.unicode_at(i % key_size))

	return result
		
