extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

# HTTPRequest object for minting cards.
var GetCardsStock: HTTPRequest = null
var wrGetCardsStock: WeakRef = null
signal get_cards_stock_complete(cards: Array)

var GetListedCards: HTTPRequest = null
var wrGetListedCards: WeakRef = null
signal get_listed_cards_complete(cards: Array)

var PopulateCardList: HTTPRequest = null
var wrPopulateCardList: WeakRef = null
signal populate_card_list_complete()

var GetCardUpgradeStock: HTTPRequest = null
var wrGetCardUpgradeStock: WeakRef = null
signal get_card_upgrade_stock_complete(cards: Array)

# Host URL for server communication.
var host: String = BKMREngine.host

#region for retrieving cards
func get_card_stock() -> void:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetCardsStock = prepared_http_req.request
	wrGetCardsStock = prepared_http_req.weakref
	
	var _get_cards_stock: int = GetCardsStock.request_completed.connect(_on_GetCardsStock_request_completed)
	var request_url: String = host + "/admin/card/stock"
	
	BKMREngine.send_get_request(GetCardsStock, request_url)
	
# Callback function
func _on_GetCardsStock_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	if is_instance_valid(GetCardsStock):
		BKMREngine.free_request(wrGetCardsStock, GetCardsStock)
	
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json_body == null:
		get_cards_stock_complete.emit({ "error": "Error retrieving cards" })
		return
		
	if status_check:
		if json_body.is_empty():
			get_cards_stock_complete.emit([])
		elif json_body.has("error"):
			get_cards_stock_complete.emit(json_body.error)
		elif json_body:
			get_cards_stock_complete.emit(json_body)
	else:
		get_cards_stock_complete.emit({ "error": "Error retrieving cards" })
	
func get_listed_cards() -> void:
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetListedCards = prepared_http_req.request
	wrGetListedCards = prepared_http_req.weakref
	
	var _get_listed_cards: int = GetListedCards.request_completed.connect(_on_GetPostedCards_request_completed)
	var request_url: String = host + "/admin/card/listed"
	
	BKMREngine.send_get_request(GetListedCards, request_url)

# Callback function
func _on_GetPostedCards_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(GetListedCards):
		BKMREngine.free_request(wrGetListedCards, GetListedCards)
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	
	if json_body == null:
		get_listed_cards_complete.emit({"error": "Error retrieving contracts"})
		return
	if status_check:
		if json_body == []:
			get_listed_cards_complete.emit([])
		elif json_body.has("error"):
			get_listed_cards_complete.emit(json_body.error)
		elif json_body:
			get_listed_cards_complete.emit(json_body)
	else:
		get_listed_cards_complete.emit({"error": "Error retrieving contracts"})
#endregion 

func populate_card_list_from_contract(password: String) -> void:
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	PopulateCardList = prepared_http_req.request
	wrPopulateCardList  = prepared_http_req.weakref
	
	var _get_listed_cards: int = PopulateCardList.request_completed.connect(_on_PopulateCardListFromContract_request_completed)
	var request_url: String = host + "/admin/update/populate-card-list"
	
	BKMREngine.send_post_request(PopulateCardList, request_url, { "password": password })

# Callback function
func _on_PopulateCardListFromContract_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var _status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(PopulateCardList):
		BKMREngine.free_request(wrPopulateCardList, PopulateCardList)
	
	# Parse the JSON body received from the server.
	var _json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	populate_card_list_complete.emit()
	#if json_body == null:
		#get_posted_cards_complete.emit({"error": "Error retrieving contracts"})
		#return
	#if status_check:
		#if json_body == []:
			#get_posted_cards_complete.emit([])
		#elif json_body.has("error"):
			#get_posted_cards_complete.emit(json_body.error)
		#elif json_body:
			#get_posted_cards_complete.emit(json_body)
	#else:
		#populate_card_list_complete.emit({"error": "Error retrieving contracts"})

func get_card_upgrade_stock() -> void:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetCardUpgradeStock = prepared_http_req.request
	wrGetCardUpgradeStock = prepared_http_req.weakref
	
	var _get_cards_stock: int = GetCardUpgradeStock.request_completed.connect(_on_GetCardUpgradeStock_request_completed)
	var request_url: String = host + "/admin/upgrade/card-level"
	
	BKMREngine.send_get_request(GetCardUpgradeStock, request_url)

	
# Callback function
func _on_GetCardUpgradeStock_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	if is_instance_valid(GetCardUpgradeStock):
		BKMREngine.free_request(wrGetCardUpgradeStock, GetCardUpgradeStock)
	
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json_body == null:
		get_card_upgrade_stock_complete.emit({ "error": "Error retrieving card upgrade items" })
		return
		
	if status_check:
		if json_body.is_empty():
			get_card_upgrade_stock_complete.emit([])
		elif json_body.has("error"):
			get_card_upgrade_stock_complete.emit(json_body.error)
		elif json_body:
			get_card_upgrade_stock_complete.emit(json_body)
	else:
		get_card_upgrade_stock_complete.emit({ "error": "Error retrieving cards" })
	
