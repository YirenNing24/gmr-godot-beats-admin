extends Node2D

const DEFAULT_LENGTH_OFFSET: int = 18
const STATIC_COLOR: Color = Color("cfaa38")
const PLAYBACK_COLOR: Color = Color("FF03BC")

@export var is_static: bool = false

var speed: int = 0
var speed_scale: int = 1
var curr_speed: int = 0

var length: float = EDITOR_C.WAVEFORM_H * 5.5
var length_offset: int = 10

var pointer: PackedVector2Array = PackedVector2Array()

func _ready() -> void:
	set_process(true)
	
	if is_static:
		var _p1: bool = pointer.push_back(Vector2(5, 0))
		var _p2: bool = pointer.push_back(Vector2(-5, 0))
		var _p3: bool = pointer.push_back(Vector2(0, 5))

func start() -> void:
	curr_speed = speed

func stop() -> void:
	curr_speed = 0

func set_length_offset(val: int) -> void:
	length_offset = val
	queue_redraw()

func _draw() -> void:
	var final_length: float = length + length_offset + DEFAULT_LENGTH_OFFSET
	
	if is_static:
		draw_colored_polygon(pointer, STATIC_COLOR)
		draw_line(Vector2(0, 0), Vector2(0, final_length), STATIC_COLOR, 1)
	else:
		draw_line(Vector2(0, 0), Vector2(0, final_length), PLAYBACK_COLOR, 1)
