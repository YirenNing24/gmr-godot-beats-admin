extends VBoxContainer

signal update_card_button_pressed


func _on_update_card_listings_button_up() -> void:
	update_card_button_pressed.emit()


func _on_confirm_password_modal_password_field_submitted(password: String) -> void:
	BKMREngine.Stocks.populate_card_list_from_contract(password)
