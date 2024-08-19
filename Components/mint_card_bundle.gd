extends VBoxContainer

signal add_card_button_pressed
signal on_card_pack_settings_pressed(card_pack: Dictionary)

const card_scene: PackedScene = preload("res://Components/PostCardComponents/card.tscn")
const chosen_card_scene: PackedScene = preload("res://Components/CardBundleComponents/card.tscn")
const card_pack_scene: PackedScene = preload("res://Components/CardBundleComponents/card_pack_settings.tscn")


@onready var are_you_sure_modal: Panel = %AreYouSureModal
@onready var cards_container: GridContainer = %CardsContainer
@onready var pack_name_field: LineEdit = %PackNameField
@onready var card_pack_settings_container: VBoxContainer = %CardPackSettingsContainer

var chosen_cards: Array[String]
var card_pack_data: Array[Dictionary]


func _ready() -> void:
	connect_signals()
	
	
func connect_signals() -> void:
	BKMREngine.Gacha.create_card_pack_settings_complete.connect(_on_create_card_pack_settings_complete)
	BKMREngine.Gacha.get_pack_settings_complete.connect(_on_create_get_pack_settings_complete)


func _on_create_card_pack_settings_complete(_message: Dictionary) -> void:
	pass


func _on_create_get_pack_settings_complete(pack_settings: Array) -> void:
	var card_pack: Control
	for pack_setting: Dictionary in pack_settings:
		card_pack = card_pack_scene.instantiate()
		card_pack_settings_container.add_child(card_pack)
		card_pack.card_pack_data(pack_setting)
		card_pack.on_card_pack_setings_pressed.connect(card_pack_settings_pressed)
		
		
func card_pack_settings_pressed(pack_data: Dictionary) -> void:
	on_card_pack_settings_pressed.emit(pack_data)


func _on_add_card_button_pressed() -> void:
	add_card_button_pressed.emit()


func _on_card_bundle_modal_selected_card(card_data: Dictionary) -> void:
	chosen_cards.append(card_data.name)
	
	var chosen_card: Control = chosen_card_scene.instantiate()
	chosen_card.name = card_data.name
	#chosen_card.get_node("CardImage").texture = card_data.texture
	cards_container.add_child(chosen_card)


func _on_review_button_pressed() -> void:
	for card: Control in cards_container.get_children():
		var card_name: String = card.name
		var weight: String = card.get_node('HBoxContainer/WeightField').text
		card_pack_data.append({
			"cardName": card_name, 
			"weight": int(weight)
				}
			)
	are_you_sure_modal.visible = true
		
		
func _on_are_you_sure_modal_are_you_sure_yes_pressed() -> void:
	var pack_data: Dictionary = {
		"cardPackData": card_pack_data,
		"packName": pack_name_field.text
	}
	BKMREngine.Gacha.create_card_pack_settings(pack_data)


func _on_are_you_sure_modal_are_you_sure_no_pressed() -> void:
	card_pack_data.clear()


func _on_visibility_changed() -> void:
	if visible:
		BKMREngine.Gacha.get_pack_settings()
		
