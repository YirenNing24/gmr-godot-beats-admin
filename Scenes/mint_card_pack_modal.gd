extends Panel

const card_pack_content_scene: PackedScene = preload("res://Components/CardBundleComponents/card_pack_content.tscn")

@onready var uploaded_image: TextureRect = %UploadedImage
@onready var upload_background: TextureRect = %UploadBackground

var uploaded_image_buffer: PackedByteArray


func _ready() -> void:
	pass


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if visible:
				visible = false


func _on_mint_card_bundle_window_on_card_pack_settings_pressed(card_pack_data: Dictionary) -> void:
	var card: Control
	for card_pack: Dictionary in card_pack_data.cardPackData:
		%PackName.text = card_pack_data.packName
		card = card_pack_content_scene.instantiate()
		card.get_node("Panel/HBoxContainer/VBoxContainer/CardName").text = card_pack.cardName
		card.get_node("Panel/HBoxContainer/VBoxContainer2/Weight").text = "WEIGHT: " + str(card_pack.weight)
		%CardPackContentContainer.add_child(card)
	visible = true


func _on_visibility_changed() -> void:
	if not visible:
		for content: Control in %CardPackContentContainer.get_children():
			content.queue_free()
		

func _on_submit_button_pressed() -> void:
	var mint_card_pack_data: Dictionary = {
		"name": %PackName.text,
		"description": "test",
		"supply": int(%Quantity.text),
		"imageByte": uploaded_image_buffer
	}
	BKMREngine.Mint.mint_card_pack(mint_card_pack_data)


func _on_open_file_dialog_button_pressed() -> void:
	%FileDialog.visible = true


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
