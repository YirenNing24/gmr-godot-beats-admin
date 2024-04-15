extends VBoxContainer

@onready var username_label: Label = %UsernameLabel
@onready var status_label: Label = %UsernameLabel


func _ready() -> void:
	connect_signal()
	
func connect_signal() -> void:
	BKMREngine.Websocket.notification_status.connect(_on_user_status_changed)
	
func _on_user_status_changed(status: Dictionary) -> void:
	if status.eventDescription == "online":
		status_label.modulate = Color(44, 253, 0)
	else:
		status_label.modulate = Color(229, 30, 0)
		
	username_label.text = status.username + "is now"
	status_label.text = status.eventDescription
