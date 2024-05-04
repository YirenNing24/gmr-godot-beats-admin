extends VBoxContainer

signal selected_upgrade_item(upgrade_item_data: Dictionary)

signal create_upgrade_item_request_sent
signal create_upgrade_item_request_complete



var card_upgrade_item_scene: PackedScene = preload("res://Components/CardUpgradeComponents/card_upgrade_item.tscn")

@onready var quantity_field: LineEdit = %QuantityField
@onready var exp_given_field: LineEdit = %ExpGivenField

@onready var card_upgrade_selection: OptionButton = %CardUpgradeSelection
@onready var tier_field: OptionButton = %TierField

@onready var upgrade_item_container: GridContainer = %UpgradeItemContainer

var image_buffer: PackedByteArray

func _ready() -> void:
	BKMREngine.Mint.create_upgrade_item_complete.connect(_on_create_upgrade_item_complete)
	BKMREngine.Stocks.get_card_upgrade_stock_complete.connect(_on_get_card_upgrade_stock_complete)
	
	var icon_texture: Texture = %CardUpgradeItemIcon.texture
	var path: String = icon_texture.resource_path
	var buffer: PackedByteArray = FileAccess.get_file_as_bytes(path)
	
	if buffer != null:
		image_buffer = buffer
	
func _on_quantity_field_text_changed(quantity_value: String) -> void:
	if quantity_value.is_valid_int():
		quantity_field.text = quantity_value
		quantity_field.caret_column = quantity_field.text.length()
	else:
		quantity_field.text = ""
		%ErrorMessageLabel.text = "You can only use numbers here"

func _on_tier_field_item_selected(index: int) -> void:
	match index:
		0:
			exp_given_field.text = "50"
		1:
			exp_given_field.text = "200"
		2:
			exp_given_field.text = "400"
		3:
			exp_given_field.text = "700"

func _on_create_upgrade_item_button_pressed() -> void:
	for field: OptionButton in get_tree().get_nodes_in_group("UpgradeItemDropdowns"):
		if field.selected == -1:
			%ErrorMessageLabel.text = "Please fill-up all the fields"
			return
		if quantity_field.text == "":
			%ErrorMessageLabel.text = "Please fill-up all the quantity field"
			return
	var create_upgrade_item_data: Dictionary = {
		"itemType": card_upgrade_selection.text.to_lower(),
		"tier": tier_field.text.to_lower(),
		"quantity": int(quantity_field.text),
		"experience": int(exp_given_field.text),
		"imageByte": image_buffer,
		"minted": true
	}
	BKMREngine.Mint.create_upgrade_item(create_upgrade_item_data)
	create_upgrade_item_request_sent.emit()

func _on_create_upgrade_item_complete(_message: Dictionary) -> void:
	create_upgrade_item_request_complete.emit()

func _on_get_card_upgrade_stock_complete(card_upgrade_items: Array) -> void:
	for child: Control in upgrade_item_container.get_children():
		child.queue_free()
		
	for card_upgrade_item: Dictionary in card_upgrade_items:
		var upgrade_item_card: Control = card_upgrade_item_scene.instantiate()
		if card_upgrade_item.tier == "tier1":
			var item_texture: Texture = preload("res://Resources/Item Upgrade Textures/general_tier1.png")
			upgrade_item_card.get_node("Panel/CardUpgradeItemIcon").texture = item_texture
		
		upgrade_item_card.get_node("Supply").text = card_upgrade_item.supply
		upgrade_item_card.get_node("Button").pressed.connect(_on_upgrade_item_card_pressed.bind(card_upgrade_item))
		upgrade_item_container.add_child(upgrade_item_card)
		
func _on_upgrade_item_card_pressed(card_upgrade_item_data: Dictionary) -> void:
	selected_upgrade_item.emit(card_upgrade_item_data)

func _on_visibility_changed() -> void:
	if visible:
		BKMREngine.Stocks.get_card_upgrade_stock()
