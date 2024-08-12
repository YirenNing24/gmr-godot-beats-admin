extends Node
class_name auth

#TODO when password error wrong, values still gets added

# Constants for utility scripts
const BKMRLocalFileStorage: Script = preload("res://BeatsKMREngine/utils/BKMRLocalFileStorage.gd")
const BKMRUtils: Script = preload("res://BeatsKMREngine/utils/BKMRUtils.gd")
const BKMRLogger: Script = preload("res://BeatsKMREngine/utils/BKMRLogger.gd")
const UUID: Script = preload("res://BeatsKMREngine/utils/UUID.gd")

# Signals for various authentication and server interactions
signal bkmr_login_complete(data: Dictionary)
signal bkmr_logout_complete

signal bkmr_session_check_complete(session: Dictionary)
signal bkmr_token_renew_complete(tokens: Dictionary)
signal bkmr_regiser_player_complete(success: Dictionary)

# Variables to store authentication and session information
var tmp_username: String
var logged_in_player: String
var logged_in_player_email: String
var logged_in_anon: bool = false
var bkmr_id_token: String
var VerifyEmail: String

# Server host URL
var host: String = BKMREngine.host

# HTTPRequest instances and weakrefs for server communication
var access_token: String
var refresh_token: String

var permission: String
var RenewToken: HTTPRequest
var wrRenewToken: WeakRef

var LoginPlayer: HTTPRequest
var wrLoginPlayer: WeakRef

var RegisterPlayer: HTTPRequest
var wrRegisterPlayer: WeakRef

var ValidateSession: HTTPRequest 
var wrValidateSession: WeakRef

var VersionCheck: HTTPRequest
var wrVersionCheck: WeakRef = null

var login_timeout: int = 0
var login_timer: Timer
var complete_session_check_wait_timer: Timer

#region Login functions
# Initiates a request to log in a player with the provided username and password
func login_player(username: String, password: String) -> Node:
	# Store the username temporarily for reference in the callback function
	tmp_username = username
	
	# Prepare the HTTP request for player login
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	LoginPlayer = prepared_http_req.request
	wrLoginPlayer = prepared_http_req.weakref
	
	# Connect the callback function to handle the completion of the login request
	var _login_signal: int = LoginPlayer.request_completed.connect(_on_LoginPlayer_request_completed)
	
	# Log information about the login attempt
	BKMRLogger.info("Calling BKMREngine to log in a player")
	
	# Prepare the payload for the login request
	var payload: Dictionary = { "username": username, "password": password }
	
	# Obfuscate the password before logging and sending the request
	var payload_for_logging: Dictionary = payload
	var obfuscated_password: String = BKMRUtils.obfuscate_string(payload["password"])

	payload_for_logging["password"] = obfuscated_password
	BKMRLogger.debug("BKMREngine login player payload: " + str(payload_for_logging))
	
	# Define the request URL for player login
	var request_url: String = host + "/admin/login"
	
	# Send the POST request to initiate player login
	BKMREngine.send_login_request(LoginPlayer, request_url, payload)
	
	# Return self for potential chaining of function calls
	return self

# Callback function triggered upon completion of the player login request
func _on_LoginPlayer_request_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the HTTP response status and free the request resources
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	
	BKMREngine.free_request(wrLoginPlayer, LoginPlayer)
	# Process the response based on the status check
	if status_check:
		# Parse the JSON body of the response
		var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
		if json_body == null:
			bkmr_login_complete.emit({})
			return
		
		# Log additional information if present in the response
		if "accessToken" in json_body.keys():
			BKMRLogger.debug("Remember me access: " + str(json_body.accessToken))
		if "refreshToken" in json_body.keys():
			BKMRLogger.debug("Remember me refresh: " + str(json_body.refreshToken))
			
			# Save the session and set the player as logged in
			access_token = json_body.accessToken
			refresh_token  = json_body.refreshToken
			permission = json_body.admin

			var username: String = json_body.username
			set_player_logged_in(username)
			BKMREngine.session = true
			
			bkmr_login_complete.emit(json_body)
			renew_access_token_timer()
		elif json_body.has("error"):
			# Emit login failure if no token is present
			bkmr_login_complete.emit(json_body)
			BKMRLogger.error("BKMREngine login player failure: " + str(json_body.error))
	else:
		# Handle cases where the JSON parsing fails or the server returns an unknown error
		if JSON.parse_string(body.get_string_from_utf8()) != null:
			var json_body: Dictionary = JSON.parse_string(body.get_string_from_utf8())
			bkmr_login_complete.emit(json_body)
		else:
			bkmr_login_complete.emit({})
			print("Unknown server error")
#endregion

	
#region Register functions
func register_player(player: Dictionary) -> void:
	# This function will be called every 4 minutes
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	RegisterPlayer = prepared_http_req.request
	wrRegisterPlayer = prepared_http_req.weakref
	# Add your JWT decoding logic here
	var _new_player_signal: int = RegisterPlayer.request_completed.connect(_on_RegisterPlayer_completed)
		# Log the initiation of player session validation
	BKMRLogger.info("Calling BKMREngine to validate an existing player session")
	# Create the payload with lookup and access tokens
	var payload: Dictionary = player
	# Log the payload details	
	BKMRLogger.debug("Validate session payload: " + str(payload))
	var request_url: String = host + "/admin/register/"
	# Send the POST request for session validation
	BKMREngine.send_post_request(RegisterPlayer, request_url, payload)
	# Return the current script instance
	
func _on_RegisterPlayer_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the status of the HTTP response
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	# Free the request resources
	BKMREngine.free_request(wrRegisterPlayer, RegisterPlayer)
	# Handle the result based on the status check
	if status_check:
		var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
		if json_body == null:
			bkmr_regiser_player_complete.emit({})
			return
		if json_body.has("error"):
			BKMRLogger.error("BKMREngine register user failure: " + str(json_body.error))
			return
			
		else:	
			
			bkmr_regiser_player_complete.emit(json_body)
	else:
		# Trigger the completion of the session check with an empty result in case of failure
		bkmr_regiser_player_complete.emit({})
#endregion

func renew_access_token_timer() -> void:
	# Create a timer that fires every 4 minutes (240 seconds)
	var timer: SceneTreeTimer = get_tree().create_timer(240.0)
	var _renew: int = timer.timeout.connect(renew_access_token_timer)
	var _connect: int = timer.timeout.connect(request_new_access_token)
	# Start the timer

# Function to be called when the timer fires
func request_new_access_token() -> void:
	# This function will be called every 4 minutes
	var prepared_http_req: Dictionary = BKMREngine.prepare_http_request()
	RenewToken = prepared_http_req.request
	wrRenewToken = prepared_http_req.weakref
	# Add your JWT decoding logic here
	var _new_token_signal: int = RenewToken.request_completed.connect(_on_RequestNewAccessToken_completed)
		# Log the initiation of player session validation
	BKMRLogger.info("Calling BKMREngine to validate an existing player session")
	# Create the payload with lookup and access tokens
	var payload: Dictionary = {}
	# Log the payload details
	BKMRLogger.debug("Validate session payload: " + str(payload))
	var request_url: String = host + "/admin/renew/access"
	# Send the POST request for session validation
	BKMREngine.send_login_request(RenewToken, request_url, payload)
	# Return the current script instance
	
func _on_RequestNewAccessToken_completed(_result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	# Check the status of the HTTP response
	var status_check: bool = BKMRUtils.check_http_response(response_code, headers, body)
	# Free the request resources
	BKMREngine.free_request(wrRenewToken, RenewToken)
	# Handle the result based on the status check
	if status_check:
		var json_body: Variant = JSON.parse_string(body.get_string_from_utf8())
		if json_body == null:
			bkmr_token_renew_complete.emit({})
			return
		if json_body.has("error"):
			BKMRLogger.error("BKMREngine renew token failure: " + str(json_body.error))
			return
			
		var result_body: Dictionary = json_body
		var _bkmr_result: Dictionary = BKMREngine.build_result(result_body)
		if "refreshToken" in json_body.keys():
			BKMRLogger.debug("Remember me access: " + str(json_body.accessToken))
			# Save the session and set the player as logged in
			refresh_token = json_body.refreshToken
			access_token = json_body.accessToken
			bkmr_token_renew_complete.emit(json_body)
	else:
		# Trigger the completion of the session check with an empty result in case of failure
		bkmr_token_renew_complete.emit({})
	
#region Log-out functions
# Function to log out the player
func logout_player() -> void:
	# Clear the logged-in player information
	logged_in_player = ""
	# Remove stored session if any and log the deletion success
	refresh_token = ""
	access_token = ""
	# Emit signal indicating completion of player logout
	bkmr_logout_complete.emit()
	get_tree().quit()

# Set the currently logged-in player and configure session timeout if applicable
func set_player_logged_in(player_name: String) -> void:
	# Set the global variable for the logged-in player
	logged_in_player = player_name
	
	# Log information about the player being logged in
	BKMRLogger.info("BKMREngine - player logged in as " + str(player_name))
	
	# Check for session duration configuration in the authentication settings
	if BKMREngine.auth_config.has("session_duration_seconds") and typeof(BKMREngine.auth_config.session_duration_seconds) == 2:
		login_timeout = BKMREngine.auth_config.session_duration_seconds
	else:
		login_timeout = 0
	
	# Log information about the login timeout configuration
	BKMRLogger.info("BKMREngine login timeout: " + str(login_timeout))
	
	# If a login timeout is specified, set up the login timer
	if login_timeout != 0:
		setup_login_timer()
	
#endregion

#region Util functions
# Complete the BKMREngine session check and emit the corresponding signal.
func complete_session_check(session_check: Dictionary = {}) -> void:
	# Log a debug message indicating the completion of the session check
	BKMRLogger.debug("BKMREngine: completing session check")
	# Emit the 'bkmr_session_check_complete' signal with the provided result
	bkmr_session_check_complete.emit(session_check)

# Set up a timer to delay the emission of the 'bkmr_session_check_complete' signal.
func setup_complete_session_check_wait_timer() -> void:
	# Create a new one-shot timer
	complete_session_check_wait_timer = Timer.new()
	
	# Configure the timer to be a one-shot timer with a small wait time (0.01 seconds)
	complete_session_check_wait_timer.set_one_shot(true)
	complete_session_check_wait_timer.set_wait_time(0.01)
	
	# Connect the timeout signal of the timer to the 'complete_session_check' function
	var _session_timer_signal: int = complete_session_check_wait_timer.timeout.connect(complete_session_check)
	
	# Add the timer as a child of the current node
	add_child(complete_session_check_wait_timer)

func setup_login_timer() -> void:
	login_timer = Timer.new()
	login_timer.set_one_shot(true)
	login_timer.set_wait_time(login_timeout)
	var _timer_signal: int = login_timer.timeout.connect(on_login_timeout_complete)
	add_child(login_timer)
	
func on_login_timeout_complete() -> void:
	logout_player()
	
#endregion
