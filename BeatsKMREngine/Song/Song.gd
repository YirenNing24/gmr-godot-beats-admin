extends Node

# Preloaded scripts for utility functions and logging.
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")

# HTTPRequest object for getting song images.
var GetSongImages: HTTPRequest = null
var wrGetSongImages: WeakRef = null
signal get_song_images_complete(song_images: Array[Dictionary])

# HTTPRequest object for saving song image.
var SaveSongImage: HTTPRequest = null
var wrSaveSongImage: WeakRef = null
signal save_song_image_complete(message: Dictionary)

# Host URL for server communication.
var host: String = BKMREngine.host

#region for Song Images
# Function to save a song image by making an API request to the server.
func save_song_and_image(song_image: Dictionary) -> void:
	# Prepare the HTTP request.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	SaveSongImage = prepared_http_req.request
	wrSaveSongImage = prepared_http_req.weakref
	
	# Connect the request completion signal to the callback function.
	var _connect: int = SaveSongImage.request_completed.connect(_on_SaveSong_request_completed)
	
	# Set the payload and request URL for saving the song image.
	var payload: Dictionary = song_image
	var request_url: String = host + "/admin/songimage/save"
	
	# Send the POST request to save the song image on the server.
	BKMREngine.send_post_request(SaveSongImage, request_url, payload)

# Callback function triggered when the server responds to the save song image request.
func _on_SaveSong_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the request resources.
	if is_instance_valid(SaveSongImage):
		BKMREngine.free_request(wrSaveSongImage, SaveSongImage)
	
	# Parse the JSON body received from the server.
	var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
	
	# Check if the server update was successful.
	if status_check:
		if json_body.has("success"):
			# Log a successful song image save.
			BKMRLogger.info(json_body.success)
			# Emit a signal indicating the completion of the song image save.
			save_song_image_complete.emit(json_body)
		elif json_body.has("error"):
			# Emit a signal with the error message.
			save_song_image_complete.emit(json_body.error)
		else:
			save_song_image_complete.emit(json_body)
	else:
		save_song_image_complete.emit({"error": "Unknown server error"})
		
# Function to retrieve song images from the server.
func get_song_images() -> void:
	# Prepare an HTTP request for fetching song images.
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	GetSongImages = prepared_http_req.request
	wrGetSongImages = prepared_http_req.weakref
	
	# Connect the callback function to handle the completion of the song images request.
	var _contracts: int = GetSongImages.request_completed.connect(_onGetGetContracts_request_completed)
	
	# Log the initiation of the request to retrieve song images.
	BKMRLogger.info("Calling BKMREngine to get song images")
	
	# Construct the request URL for fetching song images.
	var request_url: String = host + "/admin/songimage/get"
	
	# Send a GET request to retrieve the song images.
	BKMREngine.send_get_request(GetSongImages, request_url)

# Callback function to handle the completion of the song images retrieval request.
func _onGetGetContracts_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check if the HTTP response indicates success.
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	# Free the HTTP request resource if it is still valid.
	if is_instance_valid(GetSongImages):
		BKMREngine.free_request(wrGetSongImages, GetSongImages)
	
	# If the HTTP response indicates success, parse the JSON response body.
	if status_check:
		# Parse the JSON response body.
		var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
		if json_body == null:
			get_song_images_complete.emit({"error": "Error retrieving song and images"})
		else:
			if json_body.has("error"):
				BKMRLogger.info(json_body.error)
			else:
				get_song_images_complete.emit(json_body)
	else:
		get_song_images_complete.emit({"error": "Unknown server error"})
#endregion
