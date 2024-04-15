extends Panel

signal password_field_submitted(password: String)

@onready var password_field: LineEdit = %PasswordField


func _ready() -> void:
	BKMREngine.Stocks.populate_card_list_complete.connect(_on_request_completed)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("close_modal"):
		if visible:
			visible = false
		for label: Label in get_tree().get_nodes_in_group("ConfirmationErrorLabels"):
			label. queue_free()
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if visible:
				visible = false
	
func _on_update_listings_window_update_card_button_pressed() -> void:
	visible = true
	
func _on_password_field_text_submitted(password: String) -> void:
	password_field_submitted.emit(password)
	
func _on_submit_button_button_up() -> void:
	var password: String = password_field.text
	password_field_submitted.emit(password)
	
func _on_request_completed() -> void:
	password_field.text = ""
	visible = false
	
