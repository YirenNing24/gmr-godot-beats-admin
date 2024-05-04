extends Panel

@onready var error_message_label: Label = %ErrorMessageLabel

@onready var uploaded_image: TextureRect = %UploadedImage
@onready var type: Label = %Type
@onready var token_id_label: Label = %TokenIDLabel
@onready var submit_button: Button = %SubmitButton

@onready var currency_field: OptionButton = %CurrencyField
@onready var price_field: LineEdit = %PriceField
@onready var quantity_field: LineEdit = %QuantityField
@onready var format_label1: Label = %FormatLabel1
@onready var format_label2: Label = %FormatLabel2

var timer: SceneTreeTimer
var is_reviewed: bool = false

var currency_name: String
var start_date: String
var end_date: String

var data_item: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

func _on_card_upgrade_item_modal_list_for_sale_button_pressed(item_data: Dictionary, image_item: Texture) -> void:
	visible = true
	if item_data.has("experience"):
		type.text = "Card Upgrade"
	uploaded_image.texture = image_item
	token_id_label.text = item_data.id
	var _button: int = submit_button.pressed.connect(_submit_button_pressed.bind(item_data.id))
	
	data_item = item_data

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if visible:
				visible = false

func _on_cancel_button_button_up() -> void:
	_on_visibility_changed()
	
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

func _submit_button_pressed() -> void:
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
			_on_submit_button_pressed()

func _on_submit_button_pressed() -> void:
	var listing_data: Dictionary = {
		"currencyName": currency_name,
		"tokenId": data_item.id,
		"quantity": int(quantity_field.text),
		"pricePerToken": int(price_field.text),
		"startTime": start_date,
		"endTime": end_date
		}
		
	BKMREngine.List.list_card_upgrade(listing_data)

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


func _on_currency_field_item_selected(currency_value: int) -> void:
	currency_name = currency_field.get_item_text(currency_value)


func _on_quantity_field_text_changed(quantity_value: String) -> void:
	if quantity_value.is_valid_int():
		quantity_field.text = quantity_value
		quantity_field.caret_column = quantity_field.text.length()
	else:
		quantity_field.text = ""
		%ErrorLabel2.text = "You can only use numbers here"
