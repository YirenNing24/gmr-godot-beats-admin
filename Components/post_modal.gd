extends Panel

signal list_for_sale_button_pressed(card_data: Dictionary, card_pic: Texture)
signal transfer_card_button_pressed(card_data: Dictionary, card_pic: Texture)

#signal choose_for_pack_button_pressed(card_data: Dictionary, card_pic: Texture)
signal list_card_request_sent
signal list_card_request_completed

@onready var uploaded_image: TextureRect = %UploadedImage
@onready var artist_label: Label = %ArtistLabel
@onready var card_name: Label = %CardName
@onready var era_label: Label = %EraLabel
@onready var rarity_label: Label  = %RarityLabel
@onready var scoreboost_label: Label = %ScoreboostLabel
@onready var healboost_label: Label = %HealboostLabel
@onready var level_label: Label = %LevelLabel
@onready var experience_label: Label = %ExperienceLabel
@onready var stars_label: Label = %StarsLabel
@onready var breakthrough_label: Label = %BreakthroughLabel
@onready var awaken_label: Label = %AwakenLabel
@onready var boostcount_label: Label = %BoostCountLabel
@onready var slot_label: Label = %SlotLabel
@onready var tier_label: Label = %TierLabel
@onready var position_label: Label = %PositionLabel
@onready var position2_label: Label = %Position2Label
@onready var group_label: Label = %GroupLabel
@onready var card_skill_label: Label = %CardSkillLabel
@onready var card_uploader_label: Label = %CardUploaderLabel
@onready var listing_id: Label = %ListingId

@onready var list_for_sale_button: Button = %ListForSaleButton
@onready var cancel_listing_button: Button = %CancelListingButton
@onready var pack_button: Button = %PackButton

@onready var transfer_button: Button = %TransferButton


var card_filter: String = "Listed"
var data_card: Dictionary
var image_card: Texture


func _ready() -> void:
	BKMREngine.List.list_card_complete.connect(_on_list_card_completed)
	init_buttons()
	connect_signal() 

func connect_signal() -> void:
	var _connect: int = list_for_sale_button.pressed.connect(_on_list_for_sale_button_pressed)

func _on_post_card_window_selected_post_card(card_data: Dictionary, filter: String) -> void:
	populate_card_labels(card_data, filter)
	
func _on_card_bundle_modal_selected_post_card(card_data: Dictionary, filter: String) -> void:
	populate_card_labels(card_data, filter)
	
func populate_card_labels(card_data: Dictionary, filter: String) -> void:
	visible = true
	var string_array: String = card_data.imageByte
	var card_image: PackedByteArray = JSON.parse_string(string_array)
	var image: Image = Image.new()
	var error: Error = image.load_png_from_buffer(card_image)
	if error != OK:
		print("Error loading image", error)
	else:
		var card_pic: Texture =  ImageTexture.create_from_image(image)
		uploaded_image.texture = card_pic
		
	artist_label.text = card_data.artist
	card_name.text = card_data.name
	era_label.text = card_data.era 
	rarity_label.text = card_data.rarity
	scoreboost_label.text = card_data.scoreboost
	healboost_label.text = card_data.healboost
	level_label.text = card_data.level
	experience_label.text = card_data.experience
	stars_label.text = card_data.stars
	breakthrough_label.text = str(card_data.breakthrough)
	awaken_label.text = card_data.awakenCount
	boostcount_label.text = card_data.boostCount
	slot_label.text = card_data.slot
	tier_label.text = card_data.tier
	position_label.text = card_data.position
	position2_label.text = card_data.position2
	group_label.text = card_data.group
	card_skill_label.text = card_data.skill
	card_uploader_label.text = card_data.uploader
	
	if card_data.has("listingId"):
		listing_id.text = str(card_data.listingId)
	else:
		listing_id.text = "Not Posted"
		
	data_card = card_data
	image_card = uploaded_image.texture
	
	card_filter = filter
	init_buttons()
	
func _on_list_for_sale_button_pressed() -> void:
	list_for_sale_button_pressed.emit(data_card, image_card)

func _on_transfer_button_pressed() -> void:
	transfer_card_button_pressed.emit(data_card, image_card)

func init_buttons() -> void:
	for button: Button in get_tree().get_nodes_in_group("ListedButtons"):
		match card_filter:
			"Listed":
				button.disabled = false
				cancel_listing_button.disabled = true
				pack_button.disabled = true
			"Posted":
				button.disabled = true
				cancel_listing_button.disabled = false
				pack_button.disabled = true
			"Pack":
				button.disabled = true
				cancel_listing_button.disabled = true
				pack_button.disabled = false
				
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("close_modal"):
		if visible:
			visible = false
		for label: Label in get_tree().get_nodes_in_group("ConfirmationErrorLabels"):
			label. queue_free()
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if visible:
				visible = false

func _on_list_modal_list_card_request_sent() -> void:
	list_card_request_sent.emit()

func _on_list_card_completed(_data: Dictionary) -> void:
	list_card_request_completed.emit()

func _on_list_modal_list_card_complete() -> void:
	BKMREngine.Stocks.get_listed_cards()
	visible = false


