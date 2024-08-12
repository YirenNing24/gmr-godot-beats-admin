extends VBoxContainer

signal card_pack_button_pressed(pack_data: Dictionary)


@onready var card_pack_scene: PackedScene = preload("res://Components/CardBundleComponents/card_pack.tscn")


func _ready() -> void:
	signal_connect()
	

func signal_connect() -> void:
	BKMREngine.Stocks.get_card_packs_complete.connect(_on_get_card_packs_complete)



func _on_get_card_packs_complete(card_pack_data: Array) -> void:
	var card_pack: Control
	for pack: Dictionary in card_pack_data:
		card_pack = card_pack_scene.instantiate()
		card_pack.card_pack_slot_data(pack)
		card_pack.card_pack_button_pressed.connect(_on_card_pack_button_pressed)
		%CardPackContainer.add_child(card_pack)
		

func _on_card_pack_button_pressed(pack_data: Dictionary) -> void:
	card_pack_button_pressed.emit(pack_data)


func _on_visibility_changed() -> void:
	if visible:
		BKMREngine.Stocks.get_card_packs()
