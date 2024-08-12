extends Panel

signal are_you_sure_yes_pressed
signal are_you_sure_no_pressed


func show_are_you_sure_modal() -> void:
	visible = true


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if visible:
				visible = false
				are_you_sure_no_pressed.emit()


func _on_yes_button_pressed() -> void:
	are_you_sure_yes_pressed.emit()
	visible = false


func _on_no_button_pressed() -> void:
	if visible:
		visible = false
	are_you_sure_no_pressed.emit()
