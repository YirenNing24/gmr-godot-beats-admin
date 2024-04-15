extends VBoxContainer

@onready var players_container: VBoxContainer = %PlayersContainer

var player_profile_node: PackedScene = preload("res://Components/PlayerManagementComponents/player_profile.tscn")
var skip: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	signal_connect()
	
func _on_visibility_changed() -> void:
	if visible:
		BKMREngine.Players.get_players_list(skip)
		
func signal_connect() -> void:
	BKMREngine.Players.get_players_list_complete.connect(_on_get_players_list_complete)

func _on_get_players_list_complete(players_list: Array) -> void:
	for player: Dictionary in players_list:
		var player_profile: Control = player_profile_node.instantiate()
		
		var sign_date: float = player.signupDate
		var ts_date: int = roundi(sign_date / 1000)
		var signup_date: String = Time.get_date_string_from_unix_time(ts_date)

		player_profile.get_node("Panel/HBoxContainer/HBoxContainer/VBoxContainer/PlayerUsername").text = player.username
		player_profile.get_node("Panel/HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/SinceLabel").text = signup_date
		player_profile.get_node("Panel/HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/HBoxContainer/AccountTypeLabel").text = player.accountType
		
		players_container.add_child(player_profile)
		
	var new_skip: int = players_list.size()
	skip += new_skip
