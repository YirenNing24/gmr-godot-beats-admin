extends SpinBox

signal changed_value(value: float)


func _on_value_changed(val: float) -> void:
	changed_value.emit(val)

	print("Value changed:", val)
