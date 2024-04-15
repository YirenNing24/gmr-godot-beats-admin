extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

# HTTPRequest object for minting cards.
var GetListedCards: HTTPRequest = null
var wrGetListedCards: WeakRef = null
signal get_listed_cards_complete(cards: Array)

var GetPostedCards: HTTPRequest = null
var wrGetPostedCards: WeakRef = null
signal get_posted_cards_complete(cards: Array)

var PopulateCardList: HTTPRequest = null
var wrPopulateCardList: WeakRef = null
signal populate_card_list_complete()

# Host URL for server communication.
var host: String = BKMREngine.host

#region for retrieving cards
func get_listed_cards() -> Node:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetListedCards = prepared_http_req.request
	wrGetListedCards = prepared_http_req.weakref
	
	var _get_listed_cards: int = GetListedCards.request_completed.connect(_on_GetListedCards_request_completed)
	var request_url: String = host + "/admin/card/list/listed"
	
	BKMREngine.send_get_request(GetListedCards, request_url)
	return self
	
# Callback function
func _on_GetListedCards_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	if is_instance_valid(GetListedCards):
		BKMREngine.free_request(wrGetListedCards, GetListedCards)
	
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json_body == null:
		get_listed_cards_complete.emit({ "error": "Error retrieving cards" })
		return
		
	if status_check:
		if json_body.is_empty():
			get_listed_cards_complete.emit([])
		elif json_body.has("error"):
			get_listed_cards_complete.emit(json_body.error)
		elif json_body:
			get_listed_cards_complete.emit(json_body)
	else:
		get_listed_cards_complete.emit({ "error": "Error retrieving cards" })
			
func get_posted_cards() -> Node:
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetPostedCards = prepared_http_req.request
	wrGetPostedCards = prepared_http_req.weakref
	
	var _get_listed_cards: int = GetPostedCards.request_completed.connect(_on_GetPostedCards_request_completed)
	var request_url: String = host + "/admin/card/list/posted"
	
	BKMREngine.send_get_request(GetPostedCards, request_url)
	return self
	
# Callback function
func _on_GetPostedCards_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(GetPostedCards):
		BKMREngine.free_request(wrGetPostedCards, GetPostedCards)
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	
	if json_body == null:
		get_posted_cards_complete.emit({"error": "Error retrieving contracts"})
		return
	if status_check:
		if json_body == []:
			get_posted_cards_complete.emit([])
		elif json_body.has("error"):
			get_posted_cards_complete.emit(json_body.error)
		elif json_body:
			get_posted_cards_complete.emit(json_body)
	else:
		get_posted_cards_complete.emit({"error": "Error retrieving contracts"})
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
