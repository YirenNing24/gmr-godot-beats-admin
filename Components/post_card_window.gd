extends VBoxContainer

signal selected_post_card(card_data: Dictionary, filter: String)

signal get_cards_request_sent
signal get_cards_request_completed

const card_scene: PackedScene = preload("res://Components/PostCardComponents/card.tscn")
@onready var card_container: GridContainer = %CardsContainer
@onready var card_filter: OptionButton = %CardFilter

var filter_match: String = "Listed"


func _ready() -> void:
	signal_connect()
	
	
func signal_connect() -> void:
	BKMREngine.Stocks.get_cards_stock_complete.connect(_on_get_cards_complete)
	BKMREngine.Stocks.get_listed_cards_complete.connect(_on_get_cards_complete)
	
	
func _on_visibility_changed() -> void:
	if visible:
		card_filter.selected = 0
		BKMREngine.Stocks.get_card_stock()
		get_cards_request_sent.emit()
	else:
		filter_match = "Listed"
		
		
func _on_get_cards_complete(cards: Array) -> void:
	
	print("ehhhh:", cards)
	# Clear existing cards
	for card: Control in card_container.get_children():
		card.queue_free()
	
	# Cache to store images by card name
	var image_cache: Dictionary = {}
	for card_data: Dictionary in cards:
		if card_data.has("name"):
			var card: Control = card_scene.instantiate()
			var card_name: String = card_data.name
			# Check if the image is already cached
			if image_cache.has(card_name):
				card.get_node("HBoxContainer/CardImage").texture = image_cache[card_name]
			else:
				var string_array: String = card_data.imageByte
				var card_image: PackedByteArray = JSON.parse_string(string_array)
				var image: Image = Image.new()
				var error: Error = image.load_png_from_buffer(card_image)
				if error != OK:
					print("Error loading image", error)
				else:
					var card_pic: Texture = ImageTexture.create_from_image(image)
					# Cache the image texture
					image_cache[card_name] = card_pic
					card.get_node("HBoxContainer/CardImage").texture = card_pic

			card.get_node("HBoxContainer/CardNameLabel").text = card_name
			card.get_node("Button").pressed.connect(_on_card_selected.bind(card_data))
			card_container.add_child(card)
	get_cards_request_completed.emit()
	
	
func _on_card_selected(card_data: Dictionary) -> void:
	selected_post_card.emit(card_data, filter_match)


func post_card_for_sale(token_id: String) -> void:
	var _card_listing_data: Dictionary = {
		"tokenId": token_id
	}


func _on_card_filter_item_selected(selected_filter: int) -> void:
	var filter: String = card_filter.get_item_text(selected_filter)
	match filter:
		"Stocks":
			BKMREngine.Stocks.get_card_stock()
		"Listed":
			BKMREngine.Stocks.get_listed_cards()
			
	filter_match = filter 
	get_cards_request_sent.emit()
		
