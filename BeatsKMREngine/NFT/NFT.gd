extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

# HTTPRequest object for minting cards.
var TransferCards: HTTPRequest = null
var wrTransferCards: WeakRef = null
signal transfer_cards_complete(message: Dictionary)

# Host URL for server communication.
var host: String = BKMREngine.host

#region for transferring a card to a player
func transfer_cards(transfer_card_data: Dictionary) -> void:
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	TransferCards = prepared_http_req.request
	wrTransferCards = prepared_http_req.weakref
	
	var _transfer_cards: int = TransferCards.request_completed.connect(_on_TransferCardsCards_request_completed)
	
	var payload: Dictionary = transfer_card_data
	var request_url: String = host + "/admin/transfer-card"
	
	BKMREngine.send_post_request(TransferCards, request_url, payload)

# Callback function
func _on_TransferCardsCards_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(TransferCards):
		BKMREngine.free_request(wrTransferCards, TransferCards)
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json_body == null:
		transfer_cards_complete.emit({"error": "Error retrieving contracts"})
		return
	if status_check:
		if json_body.has("success"):
			BKMRLogger.info(json_body.success)
			transfer_cards_complete.emit(json_body)
		else:
			transfer_cards_complete.emit(json_body)
	else:
		transfer_cards_complete.emit(json_body)
		
