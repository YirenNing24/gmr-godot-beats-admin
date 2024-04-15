extends VBoxContainer

signal dashboard_menu_button_pressed(button_name: String)

@onready var dashboard_button: Button = %DashboardWindow


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dashboard_button.button_pressed = true
	connect_signal()
	
func connect_signal() -> void:
	for button: Button in get_tree().get_nodes_in_group("DashboardMenuButton"):
		var _connect: int = button.pressed.connect(_on_dashboard_menu_button_pressed.bind(button.name))
		
func _on_dashboard_menu_button_pressed(button_name: String) -> void:
	for button: Button in get_tree().get_nodes_in_group("DashboardMenuButton"):
		if button.button_pressed:
			if button.name != button_name:
				button.button_pressed = false
			else:
				button.button_pressed = true
	dashboard_menu_button_pressed.emit(button_name)
