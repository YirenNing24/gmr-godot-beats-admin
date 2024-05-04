extends Panel

signal list_for_sale_button_pressed(item_data: Dictionary, image_item: Texture)

@onready var type: Label = %Type
@onready var tier: Label = %Tier
@onready var supply: Label = %Supply
@onready var experience: Label = %Experience
@onready var minted: Label = %Minted
@onready var id: Label = %ID

var item_data: Dictionary
var image_item: Texture

func _ready() -> void:
	pass # Replace with function body.

func _on_create_upgrade_items_selected_upgrade_item(upgrade_item_data: Dictionary) -> void:
	
	populate_card_labels(upgrade_item_data)

func populate_card_labels(upgrade_item_data: Dictionary) -> void:
	visible = true
	if upgrade_item_data.has("experience"):
		type.text = "Card Upgrade"
	tier.text  = upgrade_item_data.tier
	supply.text = str(upgrade_item_data.supply)
	experience.text = str(upgrade_item_data.experience)
	minted.text = str(upgrade_item_data.minted)
	id.text = upgrade_item_data.id
	
	item_data = upgrade_item_data
	image_item = %UploadedImage.texture
	

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if visible:
				visible = false

func _on_list_for_sale_button_pressed() -> void:
	list_for_sale_button_pressed.emit(item_data, image_item)
