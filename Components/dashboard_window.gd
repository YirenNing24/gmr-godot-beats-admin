extends VBoxContainer

@onready var username_label: Label = %UsernameLabel
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	username_label.text = USERDATA.username + "!"
