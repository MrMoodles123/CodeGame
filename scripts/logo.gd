extends Label

# script for generating the home screen game logo/text
@export var typo_text: String = "coedgaem_"
@export var correct_text: String = "codegame_"
@export var typing_speed: float = 0.2  # Time delay between each character
@export var correction_delay: float = 0.2  # Delay before starting the correction

var current_index: int = 0
var timer: Timer
var is_correcting: bool = false

func _ready():
	# Initialize the Label to start with empty text
	text = ""
	# Create a Timer node
	timer = Timer.new()
	timer.wait_time = typing_speed
	timer.one_shot = false
	
	# Connect the "timeout" signal using a Callable
	timer.connect("timeout", Callable(self, "_on_typing_timer_timeout"))
	add_child(timer)
	# Start the typing effect for the typo text
	timer.start()

func _on_typing_timer_timeout():
	if not is_correcting:
		if current_index < typo_text.length():
			# Add the next character from the typo text
			text += typo_text[current_index]
			current_index += 1
		else:
			# Wait for a moment before starting the correction
			is_correcting = true
			timer.wait_time = correction_delay
			current_index = typo_text.length()
	else:
		if current_index > 2:
			# Remove the last two characters to correct the typo
			text = text.substr(0, current_index - 2)
			current_index -= 2
		else:
			# Ensure the correct text is displayed completely
			text = correct_text
			timer.stop()
