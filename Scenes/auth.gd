extends Control

@onready var username_field: LineEdit = %UsernameField
@onready var password_field: LineEdit = %PasswordField

@onready var error_message_label: Label = %ErrorMessage
func _ready() -> void:
	connect_signal()

func connect_signal() -> void:
	BKMREngine.Auth.bkmr_login_complete.connect(_on_login_complete)
	
func _on_password_field_text_submitted(password: String) -> void:
	var submitted_username: String = username_field.text
	var submitted_password: String = password
	
	if submitted_username and submitted_password == null or "":
		return
	login(submitted_username, submitted_password)
	
func _on_sign_in_buton_pressed() -> void:
	var submitted_username: String = username_field.text
	var submitted_password: String = password_field.text
	
	if submitted_username and submitted_password == null or "":
		return
	login(submitted_username, submitted_password)

func login(username: String, password: String) -> void:
	BKMREngine.Auth.login_player(username, password)

func _on_login_complete(result: Dictionary) -> void:
	if result.is_empty():
		return
	# Check if the result contains an error.
	elif "error" in result:
		# If there is an error, play the error animation and log the message.  
		error_message_label.text = result.error
		return
	elif "username" in result:
	# If login is successful, log the user in and transition to the dashboard.
		var scene: PackedScene = preload("res://Scenes/dashboard.tscn")
		var _change_scene: Error = get_tree().change_scene_to_packed(scene)
	else:
		error_message_label.text = result.message
