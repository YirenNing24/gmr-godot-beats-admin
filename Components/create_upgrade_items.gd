extends VBoxContainer

signal create_upgrade_item_request_sent
signal create_upgrade_item_request_complete

@onready var quantity_field: LineEdit = %QuantityField
@onready var exp_given_field: LineEdit = %ExpGivenField

var image_buffer: PackedByteArray

func _ready() -> void:
	BKMREngine.Mint.create_upgrade_item_complete.connect(_on_create_upgrade_item_complete)
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
		"type": %CardUpgradeSelection.text.to_lower(),
		"tier": %TierField.text.to_lower(),
		"quantity": int(quantity_field.text),
		"experience": int(exp_given_field.text),
		"imageByte": image_buffer,
		"minted": false
	}
	
	BKMREngine.Mint.create_upgrade_item(create_upgrade_item_data)
	create_upgrade_item_request_sent.emit()

#func _on_visibility_changed() -> void:
#
	#for field: OptionButton in get_tree().get_nodes_in_group("UpgradeItemDropdowns"):
		#field.selected = -1
	#quantity_field.text = ""

func _on_create_upgrade_item_complete(_message: Dictionary) -> void:
	create_upgrade_item_request_complete.emit()
