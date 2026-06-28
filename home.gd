extends Node2D

@onready var display: Label = $Label

var current_expression: String = ""
var is_showing_result: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display.text = "0"
	# Dynamically connect all buttons inside the grid to one function
	for button in self.get_children():
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(button.text))

func _on_button_pressed(button_text: String) -> void:
	match button_text:
		"C":
			_clear_calculator()
		"=":
			_calculate_result()
		"+", "-", "*", "/":
			_add_operator(button_text)
		_:
			_add_number(button_text)

func _add_number(num_str: String) -> void:
	# If a result was just shown, typing a new number resets the screen
	if is_showing_result:
		current_expression = ""
		is_showing_result = false
	
	current_expression += num_str
	display.text = current_expression

func _add_operator(operator_str: String) -> void:
	# Allow continuing calculations after pressing equals
	if is_showing_result:
		is_showing_result = false
		
	# Avoid adding multiple operators consecutively
	if current_expression != "" and not current_expression.ends_with(" "):
		current_expression += " " + operator_str + " "
		display.text = current_expression

func _clear_calculator() -> void:
	current_expression = ""
	display.text = "0"
	is_showing_result = false

func _calculate_result() -> void:
	if current_expression == "":
		return
		
	# Use Godot's built-in Expression class to safely evaluate the string math
	var expr = Expression.new()
	var error = expr.parse(current_expression)
	
	if error == OK:
		var result = expr.execute([], null)
		if not expr.has_execute_failed():
			display.text = str(result)
			current_expression = str(result) # Store result for continuous math
			is_showing_result = true
		else:
			display.text = "Error"
	else:
		display.text = "Format Error"
