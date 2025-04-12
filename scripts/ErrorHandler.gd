extends Node
class_name ErrorHandler

enum ErrorType{
	SYNTAX_ERROR,
	INVALID_ACTION_ERROR,
	LOGICAL_ERROR,
	CUSTOM_ERROR
}
	
func handler(type: ErrorType, message: String):
	var error 
	match type:
		ErrorType.SYNTAX_ERROR:
			error = "SYNTAX ERROR"
		ErrorType.INVALID_ACTION_ERROR:
			error = "Invalid action"
		ErrorType.LOGICAL_ERROR:
			error = "Incorrect result"
		ErrorType.CUSTOM_ERROR:
			error = "Error"
			
	_display_error(error, message)	
	
func _display_error(error: String, message: String):
	print(error + ": " + message)
	
	if has_node("/root/main"):
		var main_node = get_node("/root/main")
		if main_node.has_method("output_q"):
			main_node.output_q.push_back("ERROR: " + message + "\n")
