extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

# HTTPRequest object for minting cards.
var MintCards: HTTPRequest = null
var wrMintCards: WeakRef = null
signal mint_cards_complete(message: Dictionary)

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
	
# Callback function
func _on_MintCards_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(MintCards):
		BKMREngine.free_request(wrMintCards, MintCards)
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json_body == null:
		mint_cards_complete.emit({"error": "Error retrieving contracts"})
		return
	if status_check:
		if json_body.has("success"):
			BKMRLogger.info(json_body.success)
			mint_cards_complete.emit(json_body)
		else:
			mint_cards_complete.emit(json_body)
	else:
		mint_cards_complete.emit(json_body)
		

# Function to retrive profile pic from the server.
#func get_contracts() -> Node:
	## Prepare an HTTP request for fetching private inbox data.
	#var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	#GetContracts = prepared_http_req.request
	#wrGetContracts  = prepared_http_req.weakref
	#
	## Connect the callback function to handle the completion of the private inbox data request.
	#var _contracts: int = GetContracts.request_completed.connect(_onGetGetContracts_request_completed)
	#
	## Log the initiation of the request to retrieve inbox messages.
	#BKMRLogger.info("Calling BKMREngine to get card inventory data")
	#
	## Construct the request URL for fetching private inbox data for the specified user.
	#var request_url: String = host + "/admin/contracts"
	#
	## Send a GET request to retrieve the private inbox data.
	#await BKMREngine.send_get_request(GetContracts, request_url)
	#
	## Return the current node for method chaining.
	#return self as Node
#
## Callback function to handle the completion of the private inbox data retrieval request.
#func _onGetGetContracts_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	## Check if the HTTP response indicates success.
	#var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	#
	## Free the HTTP request resource if it is still valid.
	#if is_instance_valid(GetContracts):
		#BKMREngine.free_request(wrGetContracts, GetContracts)
	#
	## If the HTTP response indicates success, parse the JSON response body.
	#if status_check:
		## Parse the JSON response body.
		#var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
		#
		#if json_body == null:
			#get_contracts_complete.emit({"error": "Error retrieving contracts"})
			#return
		#if json_body.has("error"):
			#BKMRLogger.info(json_body.error)
		#else:
			#get_contracts_complete.emit(json_body)
			#contracts = json_body
#endregion


 #"expected": {
	#"description": "",
	#"artist": "",
	#"era": "",
	#"healboost": "",
	#"awakenCount": "",
	#"boostCount": "",
	#"level": "",
	#"name": "",
	#"position": "",
	#"position2": "",
	#"rarity": "",
	#"scoreboost": "",
	#"slot": "",
	#"skill": "",
	#"tier": "",
	#"breakthrough": "",
	#"experience": "",
	#"stars": "",
	#"supply": 0,
	#"imageByte": ""
  #},

#"found": {
	#"artist": "Ffafa",
	#"awakenCount": "0",
	#"boostCount": "0",
	#"breakthrough": false,
	#"description": "fadfasdasd",
	#"era": "Dadad",
	#"experience": "0",
	#"group": "daddaadad",
	#"healboost": "10",
	#"imageByte": 
