extends Control

signal on_card_pack_setings_pressed(pack_data: Dictionary)



func card_pack_data(pack_data: Dictionary) -> void:
	%PackName.text = pack_data.packName 
	
	var card_count: int = pack_data.cardPackData.size()
	%CardCount.text = str(card_count) + " " + get_card_text(card_count)
	%Button.pressed.connect(card_pack_setings_pressed.bind(pack_data))
	
	
func card_pack_setings_pressed(pack_data: Dictionary) -> void:
	on_card_pack_setings_pressed.emit(pack_data)


func get_card_text(count: int) -> String:
	if count != 1:
		return "cards"
	return "card"
