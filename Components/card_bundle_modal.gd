extends Panel

signal selected_card(card_data: Dictionary)
signal get_cards_unpacked_request_completed

const card_scene: PackedScene = preload("res://Components/PostCardComponents/card.tscn")

@onready var card_container: GridContainer = %CardsContainer


var chosen_cards: Array[String]


func _ready() -> void:
	connect_signals()


func connect_signals() -> void:
	var _1: int = BKMREngine.Stocks.get_cards_unpacked_complete.connect(_on_post_card_bundle_window_card_bundle_data)


func _on_mint_card_bundle_window_add_card_button_pressed() -> void:
	if visible == false:
		BKMREngine.Stocks.get_card_unpacked()
		get_cards_unpacked_request_completed.emit()
		visible = true
		
		
func _on_post_card_bundle_window_card_bundle_data(cards: Array) -> void:
	# Create a Set to track added card names
	var added_card_names: Dictionary = {}

	# Clear the existing children in card_container
	for card: Control in card_container.get_children():
		card.queue_free()

	# Iterate over the card data
	for card_data: Dictionary in cards:
		if card_data.has("name"):
			var card_name: String = card_data.name

		# Check if the card name is already added
			if card_name in added_card_names or card_name in chosen_cards:
				continue  # Skip adding this card

		# Mark the card name as added
			added_card_names.get_or_add(card_name)

			var card_pic: Texture
			var card: Control = card_scene.instantiate()
			var string_array: String = card_data.imageByte
			var card_image: PackedByteArray = JSON.parse_string(string_array)
			var image: Image = Image.new()
			var error: Error = image.load_png_from_buffer(card_image)
			
			if error != OK:
				print("Error loading image", error)
			else:
				card_pic = ImageTexture.create_from_image(image)
				card.get_node("HBoxContainer/CardImage").texture = card_pic
				card_container.add_child(card)
				
			card.get_node("HBoxContainer/CardNameLabel").text = card_name
			card_data["texture"] = card_pic
			card.get_node("Button").pressed.connect(_on_card_selected.bind(card_data))
		
		get_cards_unpacked_request_completed.emit()


func _on_card_selected(card_data: Dictionary) -> void:
	visible = false
	var card_name: String = card_data.name
	chosen_cards.append(card_name)
	selected_card.emit(card_data)
	
	
func populate_chosen_cards() -> void:
	pass
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if visible:
				visible = false
				
