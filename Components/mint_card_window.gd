extends VBoxContainer

signal review_button_pressed(error: bool, mint_data_or_error: Array)
signal request_completed()


@onready var file_dialog: FileDialog = %FileDialog
@onready var uploaded_image: TextureRect = %UploadedImage
@onready var upload_background: TextureRect = %UploadBackground

@onready var artist_name_field: LineEdit = %ArtistNameField
@onready var era_name_field: LineEdit = %EraNameField
@onready var rarity_name_field: OptionButton = %RarityNameField

@onready var card_scoreboost_field: LineEdit = %CardScoreBoostField
@onready var card_healboost_field: LineEdit = %CardHealBoostField
@onready var card_level_field: LineEdit = %CardLevelField
@onready var card_experience_field: LineEdit = %CardExperienceField

@onready var card_tier_field: LineEdit = %CardTierField
@onready var card_position_field: LineEdit = %CardPositionField
@onready var card_position2_field: LineEdit = %CardPosition2Field
@onready var card_group_field: LineEdit = %CardGroupField
@onready var card_skill_field: OptionButton = %CardSkillField

@onready var card_stars_field: LineEdit = %CardStarsField
@onready var card_breakthrough_field: OptionButton = %CardBreakthroughField
@onready var card_awaken_count_field: LineEdit = %CardAwakenCountField
@onready var card_boost_count_field: LineEdit = %CardBoostCountField
@onready var card_slot_field: LineEdit = %CardSlotField

@onready var card_supply_field: LineEdit = %CardSupplyField
@onready var card_description_field: LineEdit = %CardDescriptionField


@onready var error_label: Label = %ErrorLabel

var artist_name: String
var era_name: String
var rarity_name: String
var card_breakthrough: bool = false
var card_skill: String

var uploaded_image_buffer: PackedByteArray

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	signal_connect()

func signal_connect() -> void:
	BKMREngine.Mint.mint_cards_complete.connect(_on_mint_cards_complete)
	
	for fields: LineEdit in get_tree().get_nodes_in_group("MintCardFields"):
		var _connect: int = fields.focus_exited.connect(_on_fields_focus_exited)
		
func _on_mint_cards_complete(_message: Dictionary) -> void:
	request_completed.emit()
	
func _on_fields_focus_exited() -> void:
	error_label.text = ""
	
func _on_open_file_dialog_button_pressed() -> void:
	file_dialog.visible = true

func _on_file_dialog_file_selected(path: String) -> void:
	var image_buffer: PackedByteArray = FileAccess.get_file_as_bytes(path)
	if image_buffer != null:
		uploaded_image_buffer = image_buffer

	var image: Image = Image.new()
	var error: Error = image.load_png_from_buffer(image_buffer)
	if error != OK:
		print("Error loading image", error)
	else:
		var uploaded_pic: Texture =  ImageTexture.create_from_image(image)
		uploaded_image.texture = uploaded_pic
		upload_background.self_modulate = "ffffff00"
		%UploadLabel.visible = false

func _on_clear_image_button_pressed() -> void:
	uploaded_image.texture = null
	upload_background.self_modulate = "ffffff"
	%UploadLabel.visible = true

#region Field error checkers
func _on_card_description_field_text_changed(description_value: String) -> void:
	if description_value != "":
		card_description_field.text = description_value
		card_description_field.caret_column = card_description_field.text.length()
		error_label.text = ""
	else:
		error_label.text = "Description field is empty"

func _on_card_supply_field_text_changed(supply_value: String) -> void:
	if supply_value.is_valid_int():
		card_supply_field.text = supply_value
		card_supply_field.caret_column = card_supply_field.text.length()
		error_label.text = ""
	else:
		card_supply_field.text = ""
		error_label.text = "You can only use number values here"
	if supply_value == "":
		error_label.text = "Supply value field is empty"
	
func _on_artist_name_field_text_changed(artist_name_value: String) -> void:
	if artist_name_value != "":
		artist_name = artist_name_value.capitalize()
		artist_name_field.text = artist_name
		card_slot_field.text = artist_name
		artist_name_field.caret_column = artist_name_field.text.length()
		error_label.text = ""
	else:
		error_label.text = "Artist name field is empty"
	
func _on_era_name_field_text_changed(card_era_name_value: String) -> void:
	if card_era_name_value != "":
		era_name = card_era_name_value.capitalize()
		era_name_field.text = era_name
		era_name_field.caret_column = era_name_field.text.length()
		error_label.text = ""
	else:
		error_label.text = "Era name field is empty"
		
func _on_rarity_name_field_item_selected(index: int) -> void:
	rarity_name = rarity_name_field.get_item_text(index)
		
func _on_card_score_boost_field_text_changed(scoreboost_value: String) -> void:
	if scoreboost_value.is_valid_int():
		card_scoreboost_field.text = scoreboost_value
		card_scoreboost_field.caret_column = card_scoreboost_field.text.length()
		error_label.text = ""
	else:
		card_scoreboost_field.text = ""
		error_label.text = "You can only use number values here"
	if scoreboost_value == "":
		error_label.text = "Scoreboost field is empty"
		
func _on_card_heal_boost_field_text_changed(healboost_value: String) -> void:
	if healboost_value.is_valid_int():
		card_healboost_field.text = healboost_value
		card_healboost_field.caret_column = card_healboost_field.text.length()
		error_label.text = ""
	else:
		card_healboost_field.text = ""
		error_label.text = "You can only use number values here"
	if healboost_value == "":
		error_label.text = "Healboost field is empty"

func _on_card_level_field_text_changed(level_value: String) -> void:
	if level_value.is_valid_int():
		card_level_field.text = level_value
		card_level_field.caret_column = card_level_field.text.length()
		error_label.text = ""
	else:
		card_level_field.text = ""
		error_label.text = "You can only use number values here"
	if level_value == "":
		error_label.text = "Level value field is empty"
		
func _on_card_experience_field_text_changed(experience_value: String) -> void:
	if experience_value.is_valid_int():
		card_experience_field.text = experience_value
		card_experience_field.caret_column = card_experience_field.text.length()
		error_label.text = ""
	else:
		card_experience_field.text = ""
		error_label.text = "You can only use number values here"
	if experience_value == "":
		error_label.text = "Experience field is empty"
		
func _on_card_stars_field_text_changed(stars_value: String) -> void:
	if stars_value.is_valid_int():
		card_stars_field.text = stars_value
		card_stars_field.caret_column = card_stars_field.text.length()
		error_label.text = ""
	else:
		card_stars_field.text = ""
		error_label.text = "You can only use number values here"
	if stars_value == "":
		error_label.text = "Stars count field is empty"

func _on_card_breakthrough_field_item_selected(index: int) -> void:
	var breakthrough_value: String = card_breakthrough_field.get_item_text(index)
	if breakthrough_value == "True":
		card_breakthrough = true
	else:
		card_breakthrough = false
		
func _on_card_awaken_count_field_text_changed(awaken_value: String) -> void:
	if awaken_value.is_valid_int():
		card_awaken_count_field.text = awaken_value
		card_awaken_count_field.caret_column = card_awaken_count_field.text.length()
		error_label.text = ""
	else:
		card_awaken_count_field.text = ""
		error_label.text = "You can only use number values here"
	if awaken_value == "":
		error_label.text = "Awaken count field is empty"

func _on_card_boost_count_field_text_changed(boost_count_value: String) -> void:
	if boost_count_value.is_valid_int():
		card_boost_count_field.text = boost_count_value
		card_boost_count_field.caret_column = card_boost_count_field.text.length()
		error_label.text = ""
	else:
		card_boost_count_field.text = ""
		error_label.text = "You can only use number values here"
	if boost_count_value == "":
		error_label.text = "Boost count field is empty"

func _on_card_slot_field_text_changed(slot_value: String) -> void:
	if slot_value != "":
		card_slot_field.text = slot_value.capitalize()
		card_slot_field.caret_column = card_slot_field.text.length()
		error_label.text = ""
	else:
		error_label.text = "Card slot field is empty"

func _on_card_tier_field_text_changed(tier_value: String) -> void:
	if tier_value != "":
		card_tier_field.text = tier_value.capitalize()
		card_tier_field.caret_column = card_tier_field.text.length()
		error_label.text = ""
	else:
		error_label.text = "Card tier field is empty"
	
func _on_card_position_field_text_changed(position1_value: String) -> void:
	if position1_value != "":
		card_position_field.text = position1_value.capitalize()
		card_position_field.caret_column = card_position_field.text.length()
		error_label.text = ""
	else:
		error_label.text = "Card position field is empty"
	
func _on_card_position_2_field_text_changed(position2_value: String) -> void:
	if position2_value != "":
		card_position2_field.text = position2_value.capitalize()
		card_position2_field.caret_column = card_position2_field.text.length()
		error_label.text = ""
	else:
		error_label.text = "Card position 2 field is empty"

func _on_card_group_field_text_changed(group_value: String) -> void:
	print(group_value)
	if group_value != "":
		card_group_field.text = group_value
		card_group_field.caret_column = card_group_field.text.length()
		error_label.text = ""
	else:
		error_label.text = "Card group field is empty"

func _on_card_skill_field_item_selected(index: int) -> void:
	card_skill = card_skill_field.get_item_text(index)

func _submit_error_check() -> void:
		for fields: LineEdit in get_tree().get_nodes_in_group("MintCardFields"):
			if fields.text == "":
				pass

#endregion

func _on_review_button_pressed() -> void:
	var data: Array = []
	var empty_field: bool = false
	
	if uploaded_image.texture == null:
		data.append("Card image is empty")

	for fields: LineEdit in get_tree().get_nodes_in_group("MintCardFields"):
		if fields.text == "":
			var caps: String = fields.name.capitalize()
			var field_names: String = caps.replace("Card ", "") + " is empty"
			data.append(field_names)
			empty_field = true
	for dropdown: OptionButton in get_tree().get_nodes_in_group("MintCardDropdowns"):
		if dropdown.selected == -1:
			if dropdown.name == "RarityNameField":
				data.append("Rarity field is empty")
				empty_field = true
			elif dropdown.name == "CardSkillField":
				data.append("Skill field is empty")
				
	review_button_pressed.emit(true, data)
			
	if empty_field == false:
		submit_card_data_review()
		
func submit_card_data_review() -> void:
	var card_name: String = artist_name + " " + era_name + " " + rarity_name
	var mint_card_data: Dictionary = {
		"name": card_name,
		"description": card_description_field.text,
		"era": era_name_field.text,
		"group": card_group_field.text,
		"artist": artist_name,
		"healboost": card_healboost_field.text,
		"slot": card_slot_field.text,
		"level": card_level_field.text,
		"awakenCount": card_awaken_count_field.text,
		"boostCount": card_boost_count_field.text,
		"position": card_position_field.text,
		"position2": card_position2_field.text,
		"rarity": rarity_name,
		"scoreboost": card_scoreboost_field.text,
		"skill": card_skill,
		"tier": card_tier_field.text,
		"breakthrough": card_breakthrough,
		"stars": card_stars_field.text,
		"experience": card_experience_field.text,
		"supply": int(card_supply_field.text),
		"imageByte": uploaded_image_buffer,
	}
	#BKMREngine.Mint.mint_cards(mint_card_data)
	review_button_pressed.emit(false, [mint_card_data])
