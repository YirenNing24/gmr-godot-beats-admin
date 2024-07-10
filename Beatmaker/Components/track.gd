extends Control

@onready  var bars_container: Control = %BarsContainer
@onready  var editor: Control = get_node("/root/Main")
var bar_scene: PackedScene = preload("res://Beatmaker/Components/bar.tscn")

var color: Color = EDITOR_C.DEFAULT_COLOR
var bars: Array = []
var bars_data: Array = []
var bars_count: int = 0
var real_size: Vector2
var start_pos: int = 0
var curr_scale: float = 1.2
var track_index: int 

var size_updated: bool = false
var start_pos_updated: bool = true
var is_active: bool = false

func _ready() -> void:
	spawn_bars()
	set_process(true)

func _process(_delta: float) -> void:
	if real_size != null and not size_updated:
		update_size()
		size_updated = true
	if not start_pos_updated:
		update_start_position()
		start_pos_updated = true

func setup(bar_count: int, update_existing: bool = false) -> void:
	bars_count = bar_count
	if update_existing:
		respawn_bars()

func spawn_bars() -> void:
	clear_bars()
	var x: int = 0
	if bars_data != []:
		for data: Dictionary in bars_data:
			var data_index: String = data.index
			var data_quarters_count: String = data.quarters_count
			var bar: Node2D = add_bar(x, int(data_index), int(data_quarters_count))
			bar.set_notes_data(data.notes)
			x += bar.get_width()
	elif bars_data == []:
		for i: int in range(bars_count):
			var bar: Node2D = add_bar(x, i, EDITOR_C.QUARTERS_COUNT)
			x += bar.get_width()

func respawn_bars() -> void:
	var curr_bars_count: int = bars.size()
	if curr_bars_count < bars_count:
		var x: int = bars[curr_bars_count - 1].position.x + bars[curr_bars_count - 1].get_width()
		for i: int in range(bars_count):
			if i >= curr_bars_count:
				var bar: Node2D = add_bar(x, i, EDITOR_C.QUARTERS_COUNT)
				x += bar.get_width()
		print("curr_bars_count < bars_count", " bars count:", bars.size())
	elif curr_bars_count > bars_count:
		for i: int in range(curr_bars_count):
			var bars_node: Node2D = bars[i]
			if i >= bars_count: 
				bars_container.remove_child(bars_node)
		var _bars_resize: int = bars.resize(bars_count)
		print("curr_bars_count > bars_count", " bars count:", bars.size())

func set_info() -> void:
	color = Color.PINK
	real_size = custom_minimum_size

func update_size() -> void:
	custom_minimum_size = real_size
	bars_container.visible = true

func get_height() -> int:
	return EDITOR_C.TRACKS_DISTANCE + get_max_bar_height() as int
	
func update_scale(value: int) -> void:
	curr_scale = value
	for bar: Node in bars:
		bar.update_scale(value)
	var bars_container_y: float = bars_container.position.y
	bars_container.position = Vector2(start_pos * value, bars_container_y)	

func clear_bars() -> void:
	for bar: Node2D in bars:
		bars_container.remove_child(bar)
	bars = []

func add_bar(x: int, index: int, quarters_count: int) -> Node2D:
	var bar: Node2D = bar_scene.instantiate()
	bar.track_index = track_index
	bar.index = index
	bar.quarters_count = quarters_count
	bar.set_x_position(x)
	bars.append(bar)
	bars_container.call_deferred("add_child", bar)
	return bar as Node2D

func get_data() -> Dictionary:
	var data_bars: Array = []
	for bar: Node2D in bars:
		data_bars.append({
			index = bar.index, 
			quarters_count = bar.quarters_count, 
			notes = bar.get_notes_data()
		})
	return {
		color = color.to_html(), 
		bars = data_bars
	}

func set_data(track_data: Dictionary) -> void:
	var track_data_color: Color = track_data.color
	color = Color(track_data_color)
	bars_data = track_data.bars

func set_start_position(value: int) -> void:
	start_pos = value
	start_pos_updated = false

func update_start_position() -> void: 
	bars_container.position = Vector2(start_pos * curr_scale, bars_container.position.y)

func update_height() -> void:
	custom_minimum_size = Vector2(size.x, get_height())
	editor.update_cursor_length()

func get_max_bar_height() -> int:
	var max_height: int = 0
	for bar: Node in bars:
		var height: int = bar.get_height()
		if height > max_height:
			max_height = height
	return max_height

func set_active(value: bool) -> void:
	is_active = value
