extends Node2D

@onready var bar: Node2D = get_node('../')

const LINE_COLOR: Color = Color("#242424")
const LINE_WIDTH: int = 1
const BG_COLOR: Color = Color("#3d3e40")


func _ready() -> void:
	queue_redraw()

func get_bg_color() -> Color:
	var color_value: int = bar.index / 4.0 - floor(bar.index / 4.0)
	var bg_color_interpolate: Color = BG_COLOR.lerp(Color(0.2, 0.2, 0.2), color_value)
	return bg_color_interpolate

func _draw() -> void:
	var bar_grid_height: float = bar.get_grid_height()
	var bar_grid_width: float = bar.get_width()
	var rect: Rect2 = Rect2(0, 0, bar_grid_width, bar_grid_height)
	draw_rect(rect, get_bg_color())
	var cell_counter: int = 0
	for x: int in range(bar.get_cells_count() + 1):
		@warning_ignore("narrowing_conversion")
		var col_pos: int = x * EDITOR_C.CELL_WIDTH
		var color: Color = LINE_COLOR
		if cell_counter > 0 and cell_counter < 4:color.a = 0.2
		cell_counter += 1
		if cell_counter >= 4:cell_counter = 0
		var grid_height: float = bar.get_grid_height()
		draw_line(Vector2(col_pos, 0), Vector2(col_pos, grid_height), color, LINE_WIDTH)
	for y: int in range(2):
		@warning_ignore("narrowing_conversion")
		var row_pos: int = y * EDITOR_C.CELL_HEIGHT
		var bar_width: float = bar.get_width()
		draw_line(Vector2(0, row_pos), Vector2(bar_width, row_pos), LINE_COLOR, LINE_WIDTH)
