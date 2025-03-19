extends Node

const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")


signal get_personal_mission_complete(missions: Array)
signal create_personal_mission_complete(message: Dictionary)

var GetPersonalMission: HTTPRequest
var wrGetPersonalMission: WeakRef

var CreatePersonalMission: HTTPRequest
var wrCreatePersonalMission: WeakRef

var GetCollectionMission: HTTPRequest
var wrGetCollectionMission: WeakRef

var CreateCollectionMission: HTTPRequest
var wrCreateCollectionMission: WeakRef


var host: String = BKMREngine.host


func get_personal_mission() -> void:
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetPersonalMission = prepared_http_req.request
	wrGetPersonalMission = prepared_http_req.weakref

	var _connect: int = GetPersonalMission.request_completed.connect(_onGetPersonalMission_request_completed)

	var request_url: String = host + "/reward/get/personal-missions"
	BKMREngine.send_get_request(GetPersonalMission, request_url)


# Callback function triggered upon the completion of the buy card request.
func _onGetPersonalMission_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	if status_check:
		var json_str: String = body.get_string_from_utf8()
		if json_str != "":
		
			# Parse the JSON safely
			var parsed_data: Variant = JSON.parse_string(json_str)
			var json_body: Dictionary = parsed_data

			# Check if the response contains the expected structure
			if json_body.has("error"):
				get_personal_mission_complete.emit(json_body)
			else:
				get_personal_mission_complete.emit(json_body)
		else:
			get_personal_mission_complete.emit({"error": "Unknown server error"})
			
	else:
		get_personal_mission_complete.emit({"error": "Unknown server error"})
		
		
func create_personal_mission(mission_data: Dictionary[String, Variant]) -> void:
	# Prepare HTTP request
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	CreatePersonalMission = prepared_http_req.request
	wrCreatePersonalMission = prepared_http_req.weakref

	var _connect: int = CreatePersonalMission.request_completed.connect(_onCreatePersonalMission_request_completed)

	var request_url: String = host + "/reward/create/personal-mission"
	var payload: Dictionary = mission_data
	BKMREngine.send_post_request(CreatePersonalMission, request_url, payload)

#eaabc5d9-ee6a-4bd1-87b9-20825b646635
# Callback function triggered upon the completion of the buy card request.
func _onCreatePersonalMission_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	if status_check:
		var json_str: String = body.get_string_from_utf8()
		if json_str != "":
		
			# Parse the JSON safely
			var parsed_data: Variant = JSON.parse_string(json_str)
			if parsed_data != null:
				var json_body: Dictionary = parsed_data

				# Check if the response contains the expected structure
				if json_body.has("error"):
					create_personal_mission_complete.emit(json_body)
				else:
					create_personal_mission_complete.emit(json_body)
			else:
				create_personal_mission_complete.emit({"error": "Unknown server error"})
		else:
			create_personal_mission_complete.emit({"error": "Unknown server error"})
			
	else:
		create_personal_mission_complete.emit({"error": "Unknown server error"})


func get_collection_mission() -> void:
	# Prepare HTTP request
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetCollectionMission = prepared_http_req.request
	wrGetCollectionMission = prepared_http_req.weakref

	var _connect: int = GetCollectionMission.request_completed.connect(_onGetCollectionMission_request_completed)

	var request_url: String = host + "/reward/get/collection-missions"
	BKMREngine.send_get_request(GetCollectionMission, request_url)


# Callback function triggered upon the completion of the get collection mission request.
func _onGetCollectionMission_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	if status_check:
		var json_str: String = body.get_string_from_utf8()
		if json_str != "":
		
			# Parse the JSON safely
			var parsed_data: Variant = JSON.parse_string(json_str)
			var json_body: Dictionary = parsed_data

			# Check if the response contains the expected structure
			if json_body.has("error"):
				get_personal_mission_complete.emit(json_body)
			else:
				get_personal_mission_complete.emit(json_body)
		else:
			get_personal_mission_complete.emit({"error": "Unknown server error"})
	else:
		get_personal_mission_complete.emit({"error": "Unknown server error"})
	
	
func create_collection_mission(mission_data: Dictionary[String, Variant]) -> void:
	# Prepare HTTP request
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	CreateCollectionMission = prepared_http_req.request
	wrCreateCollectionMission = prepared_http_req.weakref

	var _connect: int = CreateCollectionMission.request_completed.connect(_onCreateCollectionMission_request_completed)

	var request_url: String = host + "/reward/create/collection-mission"
	var payload: Dictionary = mission_data
	BKMREngine.send_post_request(CreateCollectionMission, request_url, payload)
	
	
# Callback function triggered upon the completion of the create collection mission request.
func _onCreateCollectionMission_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	if status_check:
		var json_str: String = body.get_string_from_utf8()
		if json_str != "":
		
			# Parse the JSON safely
			var parsed_data: Variant = JSON.parse_string(json_str)
			var json_body: Dictionary = parsed_data

			# Check if the response contains the expected structure
			if json_body.has("error"):
				create_personal_mission_complete.emit(json_body)
			else:
				create_personal_mission_complete.emit(json_body)
		else:
			create_personal_mission_complete.emit({"error": "Unknown server error"})
	else:
		create_personal_mission_complete.emit({"error": "Unknown server error"})
