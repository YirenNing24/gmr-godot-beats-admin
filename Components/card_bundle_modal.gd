extends Panel

signal selected_post_card(card_data: Dictionary, filter: String)

signal get_cards_request_sent
signal get_cards_request_completed

var card_scene: PackedScene = preload("res://Components/PostCardComponents/card.tscn")
@onready var card_container: GridContainer = %CardsContainer


func _on_post_card_bundle_window_add_card_open() -> void:
	if visible == false:
		BKMREngine.Stocks.get_listed_cards()
		get_cards_request_sent.emit()
		visible = true
		

func _on_post_card_bundle_window_card_bundle_data(cards: Array) -> void:
	for card: Control in card_container.get_children():
		card.queue_free()
		
	for card_data: Dictionary in cards:
		var card: Control = card_scene.instantiate()
		var string_array: String = card_data.imageByte
		var card_image: PackedByteArray = JSON.parse_string(string_array)
		var image: Image = Image.new()
		var error: Error = image.load_png_from_buffer(card_image)
		if error != OK:
			print("Error loading image", error)
		else:
			var card_pic: Texture =  ImageTexture.create_from_image(image)
			card.get_node("HBoxContainer/CardImage").texture = card_pic
			card_container.add_child(card)
			
		card.get_node("HBoxContainer/CardNameLabel").text = card_data.name
		card.get_node("Button").pressed.connect(_on_card_selected.bind(card_data))
	get_cards_request_completed.emit()

func _on_card_selected(card_data: Dictionary) -> void:
	visible = false
	selected_post_card.emit(card_data, "Pack")

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if visible:
				visible = false
