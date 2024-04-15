extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

# HTTPRequest object for minting cards.
var ListCard: HTTPRequest = null
var wrListCard: WeakRef = null
signal list_card_complete(message: Dictionary)

var UpdateList: HTTPRequest = null
var wrUpdateList: WeakRef = null
signal update_list_complete(message: Dictionary)


# Host URL for server communication.
var host: String = BKMREngine.host

#region for minting a card
func list_card(list_card_data: Dictionary) -> Node:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	ListCard = prepared_http_req.request
	wrListCard = prepared_http_req.weakref
	
	var _list_card: int = ListCard.request_completed.connect(_on_ListCard_request_completed)
	
	var payload: Dictionary = list_card_data
	var request_url: String = host + "/admin/list-card"
	
	BKMREngine.send_post_request(ListCard, request_url, payload)
	return self
	
# Callback function
func _on_ListCard_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(ListCard):
		BKMREngine.free_request(wrListCard, ListCard)
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json_body == null:
		list_card_complete.emit({"error": "Error listing card"})
		return
	if status_check:
		if json_body.has("success"):
			BKMRLogger.info(json_body.success)
			list_card_complete.emit(json_body)
		else:
			list_card_complete.emit(json_body)
			
	else:
		list_card_complete.emit(json_body)
		

#region function for updating card list in memgraph DB
func update_card_list() -> Node:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	UpdateList = prepared_http_req.request
	wrUpdateList = prepared_http_req.weakref
	
	var _update_list: int = UpdateList.request_completed.connect(_on_UpdateList_request_completed)
	var request_url: String = host + "/admin/update-card-list"
	
	BKMREngine.send_get_request(UpdateList, request_url)
	return self
	
# Callback function
func _on_UpdateList_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(UpdateList):
		BKMREngine.free_request(wrUpdateList, UpdateList)
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json_body == null:
		update_list_complete.emit({"error": "Error updating card list"})
		return
	if status_check:
		if json_body.has("success"):
			BKMRLogger.info(json_body.success)
			update_list_complete.emit(json_body)
		else:
			update_list_complete.emit(json_body)
	else:
		update_list_complete.emit(json_body)
#endregion
