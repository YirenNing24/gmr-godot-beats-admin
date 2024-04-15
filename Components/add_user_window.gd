extends VBoxContainer

@onready var username_field: LineEdit = %UsernameField
@onready var email_field: LineEdit = %EmailField
@onready var access_level_field: LineEdit = %AccessLevel
@onready var password_field: LineEdit = %PasswordField
@onready var confirm_password_field: LineEdit = %ConfirmPasswordField


func _ready() -> void:
	pass # Replace with function body.

func _on_sign_in_buton_pressed() -> void:
	for field: LineEdit in get_tree().get_nodes_in_group("AddUserFields"):
		if field.text == "":
			return
	if password_field.text != confirm_password_field.text:
		return
	var _new_admin: Dictionary = {
		"username": username_field.text,
		"access": access_level_field.text,
		"password": password_field.text,
		"email": email_field.text
	}
	
func _on_confirm_password_field_text_submitted(conf_password: String) -> void:
	for field: LineEdit in get_tree().get_nodes_in_group("AddUserFields"):
		
		if field.text == "":
			return
	if password_field.text != conf_password:
		return
	var new_admin: Dictionary = {
		"username": username_field.text,
		"access": access_level_field.text,
		"password": password_field.text,
		"email": email_field.text
	}
	BKMREngine.Auth.register_player(new_admin)
	


func _on_submit_button_button_up() -> void:
	for field: LineEdit in get_tree().get_nodes_in_group("AddUserFields"):
		if field.text == "":
			return
	if password_field.text != confirm_password_field.text:
		return
	var new_admin: Dictionary = {
		"username": username_field.text,
		"access": access_level_field.text,
		"password": password_field.text,
		"email": email_field.text
	}
	BKMREngine.Auth.register_player(new_admin)
