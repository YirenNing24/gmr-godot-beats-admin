extends VBoxContainer

signal card_bundle_data(cards: Array)
signal add_card_open

@onready var add_card_button: Button = %AddCardButton


func _ready() -> void:
	signal_connect()

func signal_connect() -> void:
	BKMREngine.Stocks.get_listed_cards_complete.connect(_on_get_cards_complete)
	var _connect: int = add_card_button.pressed.connect(func () -> void:
		add_card_open.emit()
		)

func _on_get_cards_complete(cards: Array) -> void:
	card_bundle_data.emit(cards)
	
func _on_post_modal_choose_for_pack_button_pressed(_card_data: Dictionary, _card_pic: Texture) -> void:
	pass # Replace with function body.
