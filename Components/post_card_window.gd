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
	# Clear existing cards
	for card: Control in card_container.get_children():
		card.queue_free()
	
	for card_metadata: Dictionary in cards:
		if card_metadata.has("metadata"):
			var card_data: Dictionary = card_metadata["metadata"]

			# Only process cards that have a "name" field
			if card_data.has("name"):
				var card_name: String = card_data["name"]
				
				# Cache the image texture
				var card_image: Texture = load("res://Resources/CardTextures/" + card_name.replace(" ", "_").to_lower() + ".png")

				# Instantiate and configure the card
				var card: Control = card_scene.instantiate()
				card.get_node("HBoxContainer/CardImage").texture = card_image
				card.get_node("HBoxContainer/CardNameLabel").text = card_name
				card.get_node("Button").pressed.connect(_on_card_selected.bind(card_data))
				
				# Add the card to the container
				card_container.add_child(card)
	
	# Emit the signal after all valid cards are processed
	get_cards_request_completed.emit()

	

func _on_card_selected(card_data: Dictionary) -> void:
	selected_post_card.emit(card_data, filter_match)


func post_card_for_sale(token_id: String) -> void:
	var _card_listing_data: Dictionary[String, String] = {
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
		
