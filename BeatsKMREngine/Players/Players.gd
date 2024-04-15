extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

signal get_players_list_complete(Players: Array)
var PlayersList: HTTPRequest
var wrPlayersList: WeakRef
var players_list: Array

var host: String = BKMREngine.host

#region for Contracts
# Function to update saved stat points by making an API request to the server.
func get_players_list(skip: int) -> Node:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	PlayersList = prepared_http_req.request
	wrPlayersList = prepared_http_req.weakref
	
	# Connect the request completion signal to the callback function.
	var _player_list: int = PlayersList.request_completed.connect(_on_GetPlayersList_request_completed)
	
	# Set the payload and request URL for updating stat points.
	var payload: Dictionary = { "skip": skip }
	var request_url: String = host + "/admin/players/list"
	
	# Send the POST request to update stat points on the server.
	BKMREngine.send_post_request(PlayersList, request_url, payload)
	return self
	
# Callback function to handle the completion of the get players list request.
func _on_GetPlayersList_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check if the HTTP response indicates success.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the HTTP request resource if it is still valid.
	if is_instance_valid(PlayersList):
		BKMREngine.free_request(wrPlayersList, PlayersList)
	
	# If the HTTP response indicates success, parse the JSON response body.
	if status_check:
		# Parse the JSON response body.
		var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
		
		if json_body == null:
			get_players_list_complete.emit({ "error": "Error retrieving players list" })
			return
		if json_body.has("error"):
			BKMRLogger.info(json_body.error)
		else:
			get_players_list_complete.emit(json_body)
			players_list = json_body
