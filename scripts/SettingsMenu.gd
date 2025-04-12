# This code is for the Settings Menu
extends Sprite2D
@onready var option_button = $OptionButton
@onready var screens_options = $ScreensOptions
@onready var music_slider = $MusicSlider
@onready var sfx_slider = $SFXSlider
@onready var check_button = $CheckButton

var settings: Array = []
# list of possible resolutions to choose from
var resolutions: Dictionary = {"Default":Vector2i(1152,648),"1080p":Vector2i(1920,1080),"720p":Vector2i(1280,720),"480p":Vector2i(854,480)}

func _ready():
	get_screens()
	get_player_settings()
	set_player_settings()

func get_player_settings():
	settings = Global.current_player.settings
	
func set_player_settings():
	music_slider.value = settings[0]
	sfx_slider.value = settings[1]
	if settings[2] == 0:
		check_button.button_pressed = false
	else:
		check_button.button_pressed = true
	option_button.selected = settings[3]
	screens_options.selected = settings[4]
	
func save_setting(index: int, val):
	Global.current_player.settings[index] = val
	Global.updatePlayerData()
# hide menu on close
func _on_exit_button_pressed():
	hide()

# adjust volume of sound effects based on slider value
func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2,linear_to_db(value))
	AudioServer.set_bus_mute(2, value < 0.05)
	save_setting(1,value)

# adjust volume of background music based on slider value
func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1,linear_to_db(value))
	AudioServer.set_bus_mute(1, value < 0.05)
	save_setting(0,value)

# toggles between fullscreen and windowed mode
func _on_check_button_toggled(toggled_on):
	if $CheckButton.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		save_setting(2,1)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		center_window()
		save_setting(2,0)

# centers the window in the center of the screen
func center_window():
	var center_of_screen = DisplayServer.screen_get_position() + (DisplayServer.screen_get_size() / 2)
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(center_of_screen - (window_size / 2))

# changes the resolution of the game to the one picked from the options
func _on_option_button_item_selected(index):
	var _window = get_window()
	var mode = _window.get_mode()
	var res = option_button.get_item_text(index)
	_window.set_mode(Window.MODE_WINDOWED)
	get_window().set_size(resolutions[res])
	center_window()
	if mode == Window.MODE_FULLSCREEN:
		_window.set_mode(Window.MODE_FULLSCREEN)
	save_setting(3,index)

# gets the number of screens and adds them as options to choose from
func get_screens():
	var num_screens = DisplayServer.get_screen_count()
	for s in num_screens:
		screens_options.add_item("Screen " + str(s))
	screens_options.selected = 0

# changes which screen the game is displayed on to the one picked from the options
func _on_screens_options_item_selected(index):
	var _window = get_window()
	var mode = _window.get_mode()
	
	_window.set_mode(Window.MODE_WINDOWED)
	_window.set_current_screen(index)
	if mode == Window.MODE_FULLSCREEN:
		_window.set_mode(Window.MODE_FULLSCREEN)
	save_setting(4,index)
