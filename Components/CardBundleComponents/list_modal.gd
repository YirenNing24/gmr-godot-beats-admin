extends Panel

signal list_card_request_sent
#signal list_card_complete

@onready var error_message_label: Label = %ErrorMessageLabel
@onready var price_field: LineEdit = %PriceField

@onready var currency_field: OptionButton = %CurrencyField
@onready var card_name_label: Label = %CardNameLabel
@onready var uploaded_image: TextureRect = %UploadedImage
@onready var submit_button: Button = %SubmitButton

@onready var format_label1: Label = %FormatLabel1
@onready var format_label2: Label = %FormatLabel2

@onready var token_id_label: Label = %TokenIDLabel


var timer: SceneTreeTimer
var is_reviewed: bool = false

var currency_name: String
var start_date: String
var end_date: String

var data_card: Dictionary
var image_card: Texture

var type: String


func _ready() -> void:
	BKMREngine.List.list_card_complete.connect(_on_list_card_complete)
	
func _process(_delta: float ) -> void:
	if timer != null:
		var time_left: int = int(timer.time_left)
		%TimeLeftLabel.text = str(time_left)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("close_modal"):
		_on_visibility_changed()
			
			
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_visibility_changed()


func _on_currency_field_item_selected(currency_value: int) -> void:
	currency_name = currency_field.get_item_text(currency_value)
		
		
func _on_start_date_field_text_changed(start_date_value: String) -> void:
	var is_valid: bool = isDateValid(start_date_value)
	if is_valid == false:
		format_label1.modulate = "de0000"
	else:
		format_label1.modulate = "ede3fcbe"
		start_date = start_date_value
		
		
func _on_end_date_field_text_changed(end_date_value: String) -> void:
	var is_valid: bool = isDateValid(end_date_value)
	if is_valid == false:
		format_label2.modulate = "de0000"
	else:
		format_label2.modulate = "ede3fcbe"
		end_date = end_date_value
		
		
func _on_price_field_text_changed(price_value: String) -> void:
	if price_value.is_valid_int():
		price_field.text = price_value
		price_field.caret_column = price_field.text.length()
	else:
		price_field.text = ""
		%ErrorLabel.text = "You can only use numbers here"


func _on_post_modal_list_for_sale_button_pressed(card_data: Dictionary, card_pic: Texture) -> void:
	visible = true
	uploaded_image.texture = card_pic
	card_name_label.text = card_data.name
	token_id_label.text = card_data.id
	
	data_card = card_data
	image_card = card_pic

	var _connect: int = submit_button.pressed.connect(submit_button_pressed)


func _on_post_card_pack_modal_list_for_sale_button_pressed(card_data: Dictionary, card_pic: Texture, item_type: String) -> void:
	visible = true
	uploaded_image.texture = card_pic
	card_name_label.text = card_data.name
	token_id_label.text = card_data.id
	
	data_card = card_data
	image_card = card_pic

	var _connect: int = submit_button.pressed.connect(submit_button_pressed)
	type = item_type


func submit_button_pressed() -> void:
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
	var listing_data: Dictionary = {
		"currencyName": currency_name,
		"tokenId": token_id,
		"quantity": 1,
		"pricePerToken": int(price_field.text),
		"startTime": start_date,
		"endTime": end_date
		}
	if type == "Pack":
		BKMREngine.List.list_card_pack(listing_data)
	else:
		BKMREngine.List.list_card(listing_data)
	list_card_request_sent.emit()


func _on_visibility_changed() -> void:
	if visible:
		visible = false
		is_reviewed = false
		submit_button.text = "SUBMIT"
		submit_button.disabled = false
		if timer != null:
			timer.time_left = 0
		for field: LineEdit in get_tree().get_nodes_in_group("ListItemFields"):
			field.text = ""
		currency_field.selected = -1
		error_message_label.text = ""
	else:
		pass

func _on_list_card_complete(_data: Dictionary) -> void:
	visible = false

func _on_cancel_button_button_up() -> void:
	_on_visibility_changed()

func field_checker() -> bool:
	# Check if any LineEdit fields are empty
	for field: LineEdit in get_tree().get_nodes_in_group("ListItemFields"):
		if field.text == "":
			error_message_label.text = "Please fill out all the fields"
			return false
	
	# Check if a currency is selected
	if currency_field.selected == -1:
		error_message_label.text = "Please choose a currency"
		return false
	# Check if all required fields are filled out
	if currency_name == "" or start_date == "" or end_date == "":
		error_message_label.text = "Please fill out all the required fields"
		return false
	
	# All checks passed
	return true

func isDateValid(date_string: String) -> bool:
	var regex: RegEx = RegEx.new()
	var _compile: int = regex.compile("^(0[1-9]|1[0-2])/(0[1-9]|1[0-9]|2[0-9]|3[01])/\\d{2}$")  # Compile the regex pattern for the date format
	return regex.search(date_string) != null
