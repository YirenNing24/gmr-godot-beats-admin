extends Panel


@onready var card_name_label: Label = %CardNameLabel
@onready var uploaded_image: TextureRect = %UploadedImage
@onready var submit_button: Button = %SubmitButton
@onready var token_id_label: LineEdit = %TokenIDLabel
@onready var error_message_label: Label = %ErrorMessageLabel

@onready var amount_field: LineEdit = %AmountField
@onready var wallet_address_field: LineEdit = %WalletAddress

var timer: SceneTreeTimer
var is_reviewed: bool = false


var data_card: Dictionary
var image_card: Texture


func _ready() -> void:
	connect_signal()

func connect_signal() -> void:
	var _connect: int = submit_button.pressed.connect(_on_submit_button_button_pressed)

func _on_post_modal_transfer_card_button_pressed(card_data: Dictionary, card_pic: Texture) -> void:
	visible = true
	uploaded_image.texture = card_pic
	card_name_label.text = card_data.name
	token_id_label.text = card_data.id
	
	data_card = card_data

func _on_submit_button_button_pressed() -> void:
	var is_filled: bool = field_checker()
	if is_filled == false:
		return
	else:
		if is_reviewed == false:
			timer = get_tree().create_timer(15.0)
			var _connect: int = submit_button.pressed.connect(func () -> void: 
				submit_button.text = "RE-SUBMIT"
				submit_button.disabled = true
				)
			var _timeout: int = timer.timeout.connect(func () -> void:
				submit_button.disabled = false
				is_reviewed = true
				)
		else:
			var token_id: String = data_card.id
			_on_submitted(token_id)
			
func _on_submitted(token_id: String) -> void:
	var amount: int = int(amount_field.text)
	var wallet_address: String = wallet_address_field.text
	
	var _transfer_card_data: Dictionary = {
		"toAddress":  wallet_address,
		"tokenIds": [token_id],
		"amounts": [amount],
	}
	#BKMREngine.NFT.transfer_cards(transfer_card_data)


func _on_cancel_button_pressed() -> void:
	_on_visibility_changed()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_visibility_changed()

func _on_visibility_changed() -> void:
	if visible:
		visible = false
		is_reviewed = false
		submit_button.text = "SUBMIT"
		submit_button.disabled = false
		if timer != null:
			timer.time_left = 0
		for field: LineEdit in get_tree().get_nodes_in_group("TransferItemFields"):
			field.text = ""
		error_message_label.text = ""
	else:
		pass

func field_checker() -> bool:
	# Check if any LineEdit fields are empty
	for field: LineEdit in get_tree().get_nodes_in_group("TransferItemFields"):
		if field.text == "":
			error_message_label.text = "Please fill out all the fields"
			return false
	# All checks passed
	return true

func _on_wallet_address_text_changed(wallet_address: String) -> void:
	if wallet_address.substr(0, 2) == "0x" and wallet_address.length() == 42:
		wallet_address_field.text = wallet_address
		wallet_address_field.caret_column = wallet_address_field.text.length()
	else:
		wallet_address_field.text = ""
		error_message_label.text = 'Address should start with "0x" or length is not 42-characters'

func _on_amount_field_text_changed(amount_value: String) -> void:
	if amount_value.is_valid_int():
		amount_field.text = amount_value
		amount_field.caret_column = amount_field.text.length()
	else:
		amount_field.text = ""
		error_message_label.text = "You can only use numbers here"
