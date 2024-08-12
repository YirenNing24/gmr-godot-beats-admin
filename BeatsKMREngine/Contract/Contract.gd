extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

# HTTPRequest object for getting contracts picture.
var GetContracts: HTTPRequest = null
var wrGetContracts: WeakRef = null
signal get_contracts_complete(contracts: Array)
var contracts: Array

# HTTPRequest object for updating contracts.
var UpdateContracts: HTTPRequest = null
var wrUpdateContracts: WeakRef = null
signal contract_update_complete(data: Dictionary)

# Host URL for server communication.
var host: String = BKMREngine.host

#region for Contracts
# Function to update saved stat points by making an API request to the server.
func update_contracts(contract_list: Dictionary) -> void:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	UpdateContracts = prepared_http_req.request
	wrUpdateContracts = prepared_http_req.weakref
	
	# Connect the request completion signal to the callback function.
	var _update_contracts: int = UpdateContracts.request_completed.connect(_on_UpdateContracts_request_completed)
	
	# Set the payload and request URL for updating stat points.
	var payload: Dictionary = contract_list
	var request_url: String = host + "/admin/update-contracts"
	
	# Send the POST request to update stat points on the server.
	BKMREngine.send_post_request(UpdateContracts, request_url, payload)
	
# Callback function triggered when the server responds to the stat points update request.
func _on_UpdateContracts_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	BKMREngine.free_request(wrUpdateContracts, UpdateContracts)
	
	# Parse the JSON body received from the server.
	var json_body: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	
	# Check if the server update was successful.
	if status_check:
		if json_body.success:
			# Log a successful stat points update.
			BKMRLogger.info(json_body.success)
			# Emit a signal indicating the completion of the stat points update.
			contract_update_complete.emit(json_body)
		else:
			# Print the JSON body if the update was not successful.
			contract_update_complete.emit(json_body)

# Function to retrive profile pic from the server.
func get_contracts() -> Node:
	# Prepare an HTTP request for fetching private inbox data.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetContracts = prepared_http_req.request
	wrGetContracts  = prepared_http_req.weakref
	
	# Connect the callback function to handle the completion of the private inbox data request.
	var _contracts: int = GetContracts.request_completed.connect(_onGetGetContracts_request_completed)
	
	# Log the initiation of the request to retrieve inbox messages.
	BKMRLogger.info("Calling BKMREngine to get card inventory data")
	
	# Construct the request URL for fetching private inbox data for the specified user.
	var request_url: String = host + "/admin/contracts"
	
	# Send a GET request to retrieve the private inbox data.
	await BKMREngine.send_get_request(GetContracts, request_url)
	
	# Return the current node for method chaining.
	return self as Node

# Callback function to handle the completion of the private inbox data retrieval request.
func _onGetGetContracts_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check if the HTTP response indicates success.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the HTTP request resource if it is still valid.
	if is_instance_valid(GetContracts):
		BKMREngine.free_request(wrGetContracts, GetContracts)
	
	# If the HTTP response indicates success, parse the JSON response body.
	if status_check:
		# Parse the JSON response body.
		var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
		
		if json_body == null:
			get_contracts_complete.emit({"error": "Error retrieving contracts"})
			return
		if json_body.has("error"):
			BKMRLogger.info(json_body.error)
		else:
			get_contracts_complete.emit(json_body)
			contracts = json_body
#endregion
