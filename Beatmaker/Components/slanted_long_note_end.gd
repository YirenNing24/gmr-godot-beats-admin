extends Control

@onready var bar: Node2D = get_node("../")
@onready var editor: Control = get_node("/root/Main")


var width_scale: int = 1
var is_active: bool = false

# Called when the node enters the scene tree for the first time.
func set_active(value: bool) -> void:
	is_active = value
	queue_redraw()

func set_width(value: float) -> void:
	width_scale = float(value) / EDITOR_C.CELL_WIDTH
	queue_redraw()

func get_width() -> float:
	return EDITOR_C.CELL_WIDTH * width_scale
