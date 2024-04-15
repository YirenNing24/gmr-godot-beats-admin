extends Node

var username: String
var access: String


func _ready() -> void:
	connect_signal()

func connect_signal() -> void:
	BKMREngine.Auth.bkmr_login_complete.connect(_on_login_complete)
	
func _on_login_complete(result: Dictionary) -> void:
	if "username" not in result:
		return
	username = result.username
	access = result.admin
	
