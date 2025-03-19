extends SpinBox

signal changed_value(value: float)


func set_tempo(tempo: float) -> void:
	value = tempo


func _on_value_changed(val: float) -> void:
	changed_value.emit(val)

	print("Value changed:", val)
