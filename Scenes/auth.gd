extends Control

# Onready variables to cache UI elements
@onready var username_field: LineEdit = %UsernameField
@onready var password_field: LineEdit = %PasswordField
@onready var error_message_label: Label = %ErrorMessage

# Called when the node is added to the scene.
func _ready() -> void:
	connect_signal()

# Connects the custom signal for login completion to a local handler.
func connect_signal() -> void:
	BKMREngine.Auth.bkmr_login_complete.connect(_on_login_complete)

# Handles the event when text is submitted in the password field.
# Attempts to log in using the provided username and password.
func _on_password_field_text_submitted(password: String) -> void:
	var submitted_username: String = username_field.text
	var submitted_password: String = password
	
	if submitted_username == "" or submitted_password == "":
		return
	login(submitted_username, submitted_password)

# Handles the event when the sign-in button is pressed.
# Attempts to log in using the provided username and password.
func _on_sign_in_buton_pressed() -> void:
	var submitted_username: String = username_field.text
	var submitted_password: String = password_field.text
	
	if submitted_username == "" or submitted_password == "":
		return
	login(submitted_username, submitted_password)

# Initiates the login process with the provided username and password.
func login(username: String, password: String) -> void:
	BKMREngine.Auth.login_player(username, password)

# Handles the completion of the login process.
# Displays error messages or transitions to the dashboard upon successful login.
func _on_login_complete(result: Dictionary) -> void:
	if result.is_empty():
		return
	elif "error" in result:
		# If there is an error, display the error message.
		error_message_label.text = result.error
		return
	elif "username" in result:
		# If login is successful, transition to the dashboard scene.
		var scene: PackedScene = preload("res://Scenes/dashboard.tscn")
		var _change_scene: Error = get_tree().change_scene_to_packed(scene)
	else:
		# Display any other message from the result.
		error_message_label.text = result.message
