extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

# HTTPRequest object for minting cards.
var MintCards: HTTPRequest = null
var wrMintCards: WeakRef = null
signal mint_cards_complete(message: Dictionary)


var MintCardPack: HTTPRequest = null
var wrMintCardPack: WeakRef = null
signal mint_card_pack_complete(message: Dictionary)

var CreateUpgradeItem: HTTPRequest = null
var wrCreateUpgradeItem: WeakRef = null
signal create_upgrade_item_complete(message: Dictionary)


# Host URL for server communication.
var host: String = BKMREngine.host

#region for minting a card
func mint_cards(mint_card_data: Dictionary) -> Node:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	MintCards = prepared_http_req.request
	wrMintCards = prepared_http_req.weakref
	
	var _mint_cardss: int = MintCards.request_completed.connect(_on_MintCards_request_completed)
	
	var payload: Dictionary = mint_card_data
	var request_url: String = host + "/admin/mint-card"
	
	BKMREngine.send_post_request(MintCards, request_url, payload)
	return self
	
	
func _on_MintCards_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(MintCards):
		BKMREngine.free_request(wrMintCards, MintCards)
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json_body == null:
		mint_cards_complete.emit({"error": "Error minting card"})
		return
	if status_check:
		if json_body.has("success"):
			BKMRLogger.info(json_body.success)
			mint_cards_complete.emit(json_body)
		else:
			mint_cards_complete.emit(json_body)
	else:
		mint_cards_complete.emit(json_body)
#endregion

func create_upgrade_item(create_upgrade_item_data: Dictionary) -> Node:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	CreateUpgradeItem = prepared_http_req.request
	wrCreateUpgradeItem = prepared_http_req.weakref
	
	var _create_upgrades: int = CreateUpgradeItem.request_completed.connect(_on_CreateUpgradeItem_request_completed)
	
	var payload: Dictionary = create_upgrade_item_data
	var request_url: String = host + "/admin/create-upgrade-item"
	
	BKMREngine.send_post_request(CreateUpgradeItem, request_url, payload)
	return self
	
	
func _on_CreateUpgradeItem_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(CreateUpgradeItem ):
		BKMREngine.free_request(wrCreateUpgradeItem , CreateUpgradeItem )
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json_body == null:
		create_upgrade_item_complete.emit({"error": "Error creating upgrade item"})
		return
	if status_check:
		if json_body.has("success"):
			BKMRLogger.info(json_body.success)
			create_upgrade_item_complete.emit(json_body)
		else:
			create_upgrade_item_complete.emit(json_body)
	else:
		create_upgrade_item_complete.emit(json_body)
		
	
func mint_card_pack(mint_card_pack_data: Dictionary) -> void:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	MintCardPack = prepared_http_req.request
	wrMintCardPack = prepared_http_req.weakref
	
	var _mint_cardss: int = MintCardPack.request_completed.connect(_on_MintCardPack_request_completed)
	
	var payload: Dictionary = mint_card_pack_data
	var request_url: String = host + "/admin/create_card_pack"
	
	BKMREngine.send_post_request(MintCardPack, request_url, payload)
	
	
func _on_MintCardPack_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(MintCards):
		BKMREngine.free_request(wrMintCardPack, MintCardPack)
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json_body == null:
		mint_card_pack_complete.emit({"error": "Error minting card pack"})
		return
	if status_check:
		if json_body.has("success"):
			mint_card_pack_complete.emit(json_body)
		else:
			mint_card_pack_complete.emit(json_body)
	else:
		mint_card_pack_complete.emit({"error": "Error minting card pack"})
#endregion
