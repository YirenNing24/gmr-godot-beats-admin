extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

# HTTPRequest object for getting contracts picture.
var GetPackSettings: HTTPRequest = null
var wrGetPackSettings: WeakRef = null
signal get_pack_settings_complete(packs: Array)


# HTTPRequest object for updating contracts.
var CreateCardPackSettings: HTTPRequest = null
var wrCreateCardPackSettings: WeakRef = null
signal create_card_pack_settings_complete(message: Dictionary)

# Host URL for server communication.
var host: String = BKMREngine.host

#region for Contracts
# Function to update saved stat points by making an API request to the server.
func create_card_pack_settings(pack_data: Dictionary) -> void:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	CreateCardPackSettings = prepared_http_req.request
	wrCreateCardPackSettings = prepared_http_req.weakref
	
	# Connect the request completion signal to the callback function.
	var _update_contracts: int = CreateCardPackSettings.request_completed.connect(_on_CreateCardPackSettings_request_completed)
	
	# Set the payload and request URL for updating stat points.
	var payload: Dictionary = pack_data
	var request_url: String = host + "/admin/card_pack/create_settings"
	
	# Send the POST request to update stat points on the server.
	BKMREngine.send_post_request(CreateCardPackSettings, request_url, payload)
	
# Callback function triggered when the server responds to the stat points update request.
func _on_CreateCardPackSettings_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	BKMREngine.free_request(wrCreateCardPackSettings, CreateCardPackSettings)
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	
	# Check if the server update was successful.
	if status_check:
		if json_body != null:
			if json_body.has("success"):
				# Log a successful stat points update.
				BKMRLogger.info(json_body.success)
				# Emit a signal indicating the completion of the stat points update.
				create_card_pack_settings_complete.emit(json_body)
			else:
				# Print the JSON body if the update was not successful.
				create_card_pack_settings_complete.emit(json_body)
		else:
			create_card_pack_settings_complete.emit({"error": "Unknown server error"})
	else: 
		create_card_pack_settings_complete.emit({"error": "Unknown server error"})


# Function to retrive profile pic from the server.
func get_pack_settings() -> void:
	# Prepare an HTTP request for fetching private inbox data.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetPackSettings = prepared_http_req.request
	wrGetPackSettings  = prepared_http_req.weakref
	
	# Connect the callback function to handle the completion of the private inbox data request.
	var _connect: int = GetPackSettings.request_completed.connect(_onGetGetPackSettings_request_completed)
	
	# Log the initiation of the request to retrieve inbox messages.
	BKMRLogger.info("Calling BKMREngine to get card inventory data")
	
	# Construct the request URL for fetching private inbox data for the specified user.
	var request_url: String = host + "/admin/card_pack/settings"
	
	# Send a GET request to retrieve the private inbox data.
	BKMREngine.send_get_request(GetPackSettings, request_url)

# Callback function to handle the completion of the private inbox data retrieval request.
func _onGetGetPackSettings_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check if the HTTP response indicates success.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the HTTP request resource if it is still valid.
	if is_instance_valid(GetPackSettings):
		BKMREngine.free_request(wrGetPackSettings, GetPackSettings)
	
	# If the HTTP response indicates success, parse the JSON response body.
	if status_check:
		# Parse the JSON response body.
		var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
		
		if json_body == null:
			get_pack_settings_complete.emit({"error": "Error pack settings"})
			return
		if json_body.has("error"):
			BKMRLogger.info(json_body.error)
		else:
			get_pack_settings_complete.emit(json_body)

#endregion
