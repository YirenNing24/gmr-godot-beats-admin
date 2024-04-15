extends Panel

signal log_out_button_pressed

func _ready() -> void:
	pass # Replace with function body.

func _on_log_out_button_pressed() -> void:
	log_out_button_pressed.emit()
