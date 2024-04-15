extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

signal get_card_inventory_complete(card_inventory_data: Dictionary)
signal get_bag_inventory_complete(bag_inventory_data: Dictionary)
signal update_card_inventory_complete(message: Dictionary)

var host: String = BKMREngine.host

var OpenCardInventory: HTTPRequest
var wrOpenCardInventory: WeakRef

var OpenBagInventory: HTTPRequest
var wrOpenBagInventory: WeakRef

var UpdateCardInventory: HTTPRequest
var wrUpdateCardInventory: WeakRef

var card_inventory: Dictionary
var bag_inventory: Dictionary

var inventory_update: Dictionary

#region Card Inventory
#
# Opens the card inventory by sending an HTTP request to the specified URL.
#
# @returns {Node} The current instance for method chaining.
#
func open_card_inventory() -> Node:
	# Prepare an HTTP request for fetching private inbox data.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	OpenCardInventory = prepared_http_req.request
	wrOpenCardInventory  = prepared_http_req.weakref
	
	# Connect the callback function to handle the completion of the private inbox data request.
	var _cards: int = OpenCardInventory.request_completed.connect(_onOpenCardInventory_request_completed)
	
	# Log the initiation of the request to retrieve inbox messages.
	BKMRLogger.info("Calling BKMREngine to get card inventory data")
	
	# Construct the request URL for fetching private inbox data for the specified user.
	var request_url: String = host + "/api/card/inventory/open"
	
	# Send a GET request to retrieve the private inbox data.
	await BKMREngine.send_get_request(OpenCardInventory, request_url)
	
	# Return the current node for method chaining.
	return self as Node

# Callback function to handle the completion of the private inbox data retrieval request.
# Parameters:
# - _result (int): The result of the HTTP request.
# - response_code (int): The HTTP response code.
# - headers (Array): The array of HTTP headers received in the response.
# - body (PackedByteArray): The packed byte array containing the response body.
# Returns:
# - void
func _onOpenCardInventory_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check if the HTTP response indicates success.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the HTTP request resource if it is still valid.
	if is_instance_valid(OpenCardInventory):
		BKMREngine.free_request(wrOpenCardInventory, OpenCardInventory)
	
	# If the HTTP response indicates success, parse the JSON response body.
	if status_check:
		# Parse the JSON response body.
		var json_body: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		if json_body.has("error"):
			BKMRLogger.info(json_body.error)
		else:
			# Emit the 'get_inbox_messages_complete' signal to notify the completion of private inbox data retrieval.
			get_card_inventory_complete.emit(json_body)
			card_inventory = json_body

func update_inventory() -> Node:
	print("heyyyy: ", card_inventory)
	# Prepare an HTTP request for fetching private inbox data.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	UpdateCardInventory = prepared_http_req.request
	wrUpdateCardInventory  = prepared_http_req.weakref
	
	# Connect the callback function to handle the completion of the private inbox data request.
	var _cards: int = UpdateCardInventory.request_completed.connect(_onUpdateInventory_request_completed)
	
	# Log the initiation of the request to retrieve inbox messages.
	BKMRLogger.info("Calling BKMREngine to get card inventory data")
	
	# Construct the request URL for fetching private inbox data for the specified user.
	var request_url: String = host + "/api/card/inventory/update"
	var payload: Dictionary = card_inventory
	# Send a GET request to retrieve the private inbox data.
	await BKMREngine.send_post_request(UpdateCardInventory, request_url, payload)
	
	# Return the current node for method chaining.
	return self as Node

func _onUpdateInventory_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check if the HTTP response indicates success.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the HTTP request resource if it is still valid.
	if is_instance_valid(OpenCardInventory):
		BKMREngine.free_request(wrUpdateCardInventory, UpdateCardInventory)
	
	# If the HTTP response indicates success, parse the JSON response body.
	if status_check:
		# Parse the JSON response body.
		var json_body: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		if json_body.has("error"):
			BKMRLogger.info(json_body.error)
		else:
			# Emit the 'get_inbox_messages_complete' signal to notify the completion of private inbox data retrieval.
			update_card_inventory_complete.emit(json_body)
			inventory_update = json_body
#endregion


#region Bag Inventory
func open_bag_inventory() -> Node:
	# Prepare an HTTP request for fetching private inbox data.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	OpenBagInventory = prepared_http_req.request
	wrOpenBagInventory  = prepared_http_req.weakref
	
	# Connect the callback function to handle the completion of the private inbox data request.
	var _cards: int = OpenBagInventory.request_completed.connect(_onOpenBagInventory_request_completed)
	
	# Log the initiation of the request to retrieve inbox messages.
	BKMRLogger.info("Calling BKMREngine to get card inventory data")
	
	# Construct the request URL for fetching private inbox data for the specified user.
	var request_url: String = host + "/api/bag/inventory/open"
	
	# Send a GET request to retrieve the private inbox data.
	await BKMREngine.send_get_request(OpenBagInventory, request_url)
	
	# Return the current node for method chaining.
	return self as Node

# Callback function to handle the completion of the private inbox data retrieval request.
# Parameters:
# - _result (int): The result of the HTTP request.
# - response_code (int): The HTTP response code.
# - headers (Array): The array of HTTP headers received in the response.
# - body (PackedByteArray): The packed byte array containing the response body.
# Returns:
# - void
func _onOpenBagInventory_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check if the HTTP response indicates success.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the HTTP request resource if it is still valid.
	if is_instance_valid(OpenBagInventory):
		BKMREngine.free_request(wrOpenBagInventory, OpenBagInventory)
	
	# If the HTTP response indicates success, parse the JSON response body.
	if status_check:
		# Parse the JSON response body.
		var json_body: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		if json_body.has("error"):
			BKMRLogger.info(json_body.error)
		else:
			# Emit the 'get_inbox_messages_complete' signal to notify the completion of private inbox data retrieval.
			get_bag_inventory_complete.emit(json_body)
			bag_inventory = json_body
#endregion
