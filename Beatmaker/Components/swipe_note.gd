extends StaticBody2D

@onready var bar: Node2D = get_node("../")
@onready var editor: Control = get_node("/root/Main")
@onready var editor_container: VBoxContainer = get_node("/root/Main/EditorContainer")
@onready var control: Control = $Control
@onready var assign_color: Panel = $AssignColor
#@onready var layer_input: LineEdit = $LayerInput
#@onready var layer_label: Label = $LayerLabel

const BORDER_LINE_W: int = 1
const CELL_SCALE_MIN: float = 0.5

var is_pressed: bool = false
var is_deleted: bool = false
var playing: bool = false
var is_active: bool = false

var width_scale: int = 1
@warning_ignore("narrowing_conversion")
var max_width: int = EDITOR_C.CELL_WIDTH
var updated_scale: int = 1
var member: String
var slanted: bool = false

var selected: bool = false 
var layer_number: int
var is_swipe: bool = true

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if editor and editor.is_playing:
		var note_x: float = global_position.x
		var cursor_x: float = editor.cursor_playback.global_position.x
		if cursor_x >= note_x and cursor_x <= note_x + max_width * bar.scale.x:
			if not playing:
				playing = true
				queue_redraw()
		elif playing:
			playing = false
			queue_redraw()
	elif playing:
		playing = false
		queue_redraw()

func get_border_color() -> Color:
	return get_note_color()

func get_note_color() -> Color:
	return bar.track.color if is_active or playing else Color.AQUAMARINE

func set_active(value: bool) -> void:
	#layer_input.visible = true
	is_active = value
	queue_redraw()

func get_width() -> float:
	return EDITOR_C.CELL_WIDTH * width_scale

func set_width(value: float) -> void:
	width_scale = int(value / EDITOR_C.CELL_WIDTH)
	queue_redraw()

func _draw() -> void:
	var width: float = get_width()
	var height: float = EDITOR_C.CELL_HEIGHT
	var rect2: Rect2 = Rect2(BORDER_LINE_W, BORDER_LINE_W, width - BORDER_LINE_W * 2, height - BORDER_LINE_W * 2)
	draw_rect(rect2, get_border_color())
	var rect: Rect2 = Rect2(BORDER_LINE_W, BORDER_LINE_W, width - BORDER_LINE_W * 3, height - BORDER_LINE_W * 3)
	draw_rect(rect, get_note_color())
	control.size = Vector2(width, height)
	assign_color.size = Vector2(width, height)

func update_scale(value: float) -> void:
	updated_scale = int(value)

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_pressed = event.pressed
			if is_pressed:
				if not is_active:
					editor.set_active_note(self)
				#layer_input.visible = true
			else:
				position = Vector2(position.x, 0)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			delete()
	elif event is InputEventMouseMotion and is_pressed:
		var width: float = event.position.x
		var s: float = round(width / EDITOR_C.CELL_WIDTH / CELL_SCALE_MIN) * CELL_SCALE_MIN
		if s >= CELL_SCALE_MIN and s * EDITOR_C.CELL_WIDTH <= max_width:
			width_scale = int(s)
			queue_redraw()

func delete() -> void:
	if not is_deleted:
		is_deleted = true
		bar.delete_note(self)
	update_scale(updated_scale)

func get_slanted_long_note_data() -> void:
	pass
