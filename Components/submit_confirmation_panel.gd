extends Panel


signal request_sent

@onready var error_label: PackedScene = preload("res://Components/ConfirmationPanelComponents/error_label.tscn")

@onready var error_container: VBoxContainer = %ErrorContainer
@onready var confirmation_container: VBoxContainer = %ConfirmationContainer

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
@onready var supply_label: Label = %SupplyLabel

@onready var submit_button: Button = %SubmitButton


var timer: SceneTreeTimer



func _process(_delta: float ) -> void:
	if timer != null:
		var time_left: int = int(timer.time_left)
		%TimeLeftLabel.text = str(time_left)
	
func _on_mint_card_window_review_button_pressed(error: bool, data: Array) -> void:
	visible = true
	if error:
		display_error(data)
	else:
		var stats_data: Dictionary = data[0]
		display_confirmation_stats(stats_data)

func display_error(error_data: Array) -> void:
	error_container.visible = true
	submit_button.disabled = true
	if confirmation_container.visible:
		confirmation_container.visible = false
		
	for error_message: String in error_data:
		var label: Label = error_label.instantiate()
		label.text = error_message
		error_container.add_child(label)

func display_confirmation_stats(stats_data: Dictionary) -> void:
	confirmation_container.visible = true
	
	if error_container.visible:
		error_container.visible = false
	var image: Image = Image.new()
	var image_array: PackedByteArray = stats_data.imageByte
	var error: Error = image.load_png_from_buffer(image_array)
	if error != OK:
		print("Error loading image", error)
	else:
		var uploaded_pic: Texture =  ImageTexture.create_from_image(image)
		uploaded_image.texture = uploaded_pic
	card_name.text = stats_data.name
	era_label.text = stats_data.era
	healboost_label.text = stats_data.healboost
	artist_label.text = stats_data.artist
	slot_label.text = stats_data.slot
	level_label.text = stats_data.level
	boostcount_label.text = stats_data.boostCount
	awaken_label.text = stats_data.awakenCount
	position_label.text = stats_data.position
	position2_label.text = stats_data.position2
	rarity_label.text = stats_data.rarity
	scoreboost_label.text = stats_data.scoreboost
	group_label.text  = stats_data.group
	card_skill_label.text = stats_data.skill
	tier_label.text = stats_data.tier
	breakthrough_label.text = str(stats_data.breakthrough)
	stars_label.text = stats_data.stars
	experience_label.text  = stats_data.experience
	supply_label.text = str(stats_data.supply)
	
	timer = get_tree().create_timer(15.0)

	var _connect: int = submit_button.pressed.connect(func () -> void: 
		BKMREngine.Mint.mint_cards(stats_data)
		request_sent.emit()
		)
		
	var _submit_enable: int = timer.timeout.connect(func () -> void: 
		submit_button.disabled = false)
	
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
				for label: Label in get_tree().get_nodes_in_group("ConfirmationErrorLabels"):
					label. queue_free()
			
