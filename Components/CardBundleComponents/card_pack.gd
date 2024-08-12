extends Control

signal card_pack_button_pressed(pack_data: Dictionary)


func card_pack_slot_data(pack_data: Dictionary) -> void:
	%PackName.text = pack_data.name
	%Button.pressed.connect(_on_card_pack_button_pressed.bind(pack_data))
	

func _on_card_pack_button_pressed(pack_data: Dictionary) -> void:
	card_pack_button_pressed.emit(pack_data)
