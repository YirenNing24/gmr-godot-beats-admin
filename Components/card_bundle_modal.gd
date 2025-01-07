extends Panel

signal selected_card(card_data: Dictionary[String, Variant])
signal get_cards_unpacked_request_completed

const card_scene: PackedScene = preload("res://Components/PostCardComponents/card.tscn")

@onready var card_container: GridContainer = %CardsContainer


var chosen_cards: Array[String]


func _ready() -> void:
	connect_signals()


func connect_signals() -> void:
	var _1: int = BKMREngine.Stocks.get_cards_unpacked_complete.connect(_on_get_cards_unpacked_complete)


func _on_mint_card_bundle_window_add_card_button_pressed() -> void:
	if visible == false:
		BKMREngine.Stocks.get_card_unpacked()
		get_cards_unpacked_request_completed.emit()
		visible = true
		

func _on_get_cards_unpacked_complete(cards: Array) -> void:
	# Clear the existing children in card_container
	for card: Control in card_container.get_children():
		card.queue_free()
	
	# Iterate over the card data
	for card_data: Dictionary in cards:
		var card_name: String = card_data.name
		
		# Check if a card with the same name already exists
		var card_exists: bool = false
		for existing_card: Control in card_container.get_children():
			if existing_card.get_node("HBoxContainer/CardNameLabel").text == card_name:
				card_exists = true
				break
		
		# If the card doesn't already exist, add it
		if not card_exists:
			var card: Control = card_scene.instantiate()
			card_container.add_child(card)
			var cards_name: String = "res://Resources/CardTextures/" + card_data.name.replace(" ", "_").to_lower() + ".png"
			var card_image: Texture = load(cards_name)
			card.get_node("HBoxContainer/CardImage").texture = card_image
			card.get_node("HBoxContainer/CardNameLabel").text = card_name
			card.get_node("Button").pressed.connect(_on_card_selected.bind(card_data))


	# Helper function to check if a card with the same name exists
func card_already_exists(card_name: String) -> bool:
	for child: Control in card_container.get_children():
		if child.get_node("HBoxContainer/CardNameLabel").text == card_name:
			return true
	return false


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
				for card: Control in card_container.get_children():
					card.queue_free()
