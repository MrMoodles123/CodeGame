extends Control

"""
Script to handle the home screen scene and its UI components
"""

@onready var leaderboard_screen = load("res://scenes/Leaderboard.tscn")
@onready var farm = $Farm	# farm grid displayed on screen
@onready var logo = $MarginContainer/TextureRect/Logo	# the typed effect logo
@onready var container = $MarginContainer
@onready var settings_menu = $MenuBG
@onready var music_player = $MusicPlayer
@onready var leaderboard_button = $MarginContainer/TextureRect/VBoxContainer/Leaderboard

var profile_panel = preload("res://scenes/profile.tscn")
var guest_panel = load("res://scenes/signup.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var cursor = load("res://Demo Art/Sprout Lands - UI Pack - Basic pack/extras/i-cursor.png")
	Input.set_custom_mouse_cursor(cursor,Input.CURSOR_IBEAM)
	center_farm()
	leaderboard_button.disabled = false
	#music_player.start_music()
	#$error_panel.visible = false
	

# handler for challenges button
func _on_challenges_pressed():
	Global.game_state = Global.GAME_STATE.CHALLENGE
	get_tree().change_scene_to_file("res://scenes/levels.tscn")

# handler for tutorial button
func _on_tutorial_pressed():
	Global.game_state = Global.GAME_STATE.TUTORIAL
	get_tree().change_scene_to_file("res://scenes/levels.tscn")


# Exits the game
func _on_quit_pressed():
	get_tree().quit()


# Functionality for the leaderboard that waits until the scores are retrieved
func _on_leaderboard_pressed():
	if Global.current_player.username == "GUEST":
		_show_guest_signup_panel()
	else:
		# restrict leaderboard display if the user is a guest
		leaderboard_button.disabled = true
		$Request_timer.start(10)
		await SilentWolf.Scores.get_scores().sw_get_scores_complete
		
		$Request_timer.stop()
		
		get_tree().change_scene_to_packed(leaderboard_screen)


# functionality for the profile button
func _on_profile_pressed() -> void:
	# restrict profile display if the user is a guest
	if Global.current_player.username == "GUEST":
		_show_guest_signup_panel()
		return
	
	# check whether profile instance already exists, else create a new popup display
	if has_node("ProfilePanel"):
		var instance = get_node("ProfilePanel")
		instance.visible = true
	
	else:
		# displays profile panel
		var instance = profile_panel.instantiate()
		instance.name = "ProfilePanel"
		add_child(instance)
		instance.visible = true
	
	
# Handler for showing the guest sign up panel
func _show_guest_signup_panel():
	# check whether guest view instance already exists, else create a new popup display
	if has_node("GuestPanel"):
		var instance = get_node("GuestPanel")
		instance.visible = true
	
	else:
		var instance = guest_panel.instantiate()
		instance.name = "GuestPanel"
		add_child(instance)
		instance.visible = true
		
		
# Configures the placement of the farm grid
func center_farm():
	var farm_scale = 3
	farm.scale = Vector2(farm_scale,farm_scale)
	var center_of_farm: int = (8*16*farm.scale.x)/2
	farm.position.y = (container.size.y / 2) - center_of_farm
	farm.position.x = (logo.global_position.x/2) - center_of_farm

# Handles the placement of settings button
func center_settings_menu():
	settings_menu.global_position.x = container.size.x / 2
	settings_menu.global_position.y = container.size.y / 2
	
# function that checks if user presses a key
func _input(event):
	if event.is_action_pressed("ui_cancel"): # default keybid in Godot to escape. This will trigger when escape key is pressed
		center_settings_menu()
		settings_menu.visible = !settings_menu.visible # toggle settings visibilty
		

func _on_settings_button_pressed():
	center_settings_menu()
	settings_menu.show()
	


func _on_request_timer_timeout():
	$error_panel.visible = true
	await get_tree().create_timer(5.0).timeout
	$error_panel.visible = false
	
