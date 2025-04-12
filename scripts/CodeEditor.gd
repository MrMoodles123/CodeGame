extends Panel

@onready var editor = $Editor
@onready var fd_save = $dialog_save
@onready var fd_load = $dialog_load

"""
Temporary script to test the functionality of the in-game code editor
"""

func _ready():
	fd_save.visible = false
	fd_load.visible = false


func _on_save_pressed():
	fd_save.visible = true


func _on_load_pressed():
	fd_load.visible = true


func _on_dialog_save_file_selected(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(editor.text)
	file.close()


func _on_dialog_load_file_selected(path):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		editor.text = file.get_as_text()
		file.close()
