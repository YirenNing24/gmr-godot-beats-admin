extends Node2D

var note_scene: PackedScene = preload("res://Beatmaker/Components/note.tscn")
var swipe_note_scene: PackedScene = preload("res://Beatmaker/Components/swipe_note.tscn")

@onready var grid: Node2D = get_node("Grid")
@onready var index_label: Label = get_node("IndexLabel")
@onready var control: Control = get_node('Control')
@onready var track: Control = get_node("../../")
@onready var editor: Control = get_node("/root/Main")
@onready var editorcontainer: VBoxContainer = get_node("/root/Main/EditorContainer")

var slanted_long_note_end_position: float
var quarters_count: int = EDITOR_C.QUARTERS_COUNT
var index: int = 0
var track_index: int
var filled_cells: Array = []
var notes: Array = []
var slanted_long_notes_end: Array = []
var x_pos: int = 0
var is_pressed: bool = false
var is_active: bool = false
var hold_ctrl: bool = false
var hold_shift: bool = false

func _ready() -> void:
	index_label.text = str(index)
	control.custom_minimum_size = Vector2(get_width(), get_height())
	#editor.connecting_slanted_long_note.connect(_on_set_slanting_node_data)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_hold_ctrl'):
		hold_ctrl = true
	elif event.is_action_released('ui_hold_ctrl'):
		hold_ctrl = false
		
	if event.is_action_pressed('ui_hold_shift'):
		hold_shift = true
	elif event.is_action_released('ui_hold_shift'):
		hold_shift = false

func get_width() -> int:
	@warning_ignore("narrowing_conversion")
	return get_cells_count() * EDITOR_C.CELL_WIDTH
	
func get_grid_height() -> int:
	@warning_ignore("narrowing_conversion")
	return EDITOR_C.CELL_HEIGHT
	
func get_height() -> int:
	return EDITOR_C.HEIGHT
	
func get_cells_count() -> int:
	return quarters_count * EDITOR_C.CELLS_IN_QUARTER_COUNT
	
func set_x_position(val: int) -> void:
	x_pos = val
	position = Vector2(x_pos, 0)

func update_scale(val: int) -> void:
	scale = Vector2(val, 1)
	position = Vector2(x_pos * val, position.y)
	index_label.set_scale(Vector2(1.0 / val, 1))
	for note: StaticBody2D in notes:
		note.update_scale(val)

func add_note(x: float) -> StaticBody2D:
	filled_cells.append(x)
	var note: StaticBody2D = note_scene.instantiate()
	note.position = Vector2(x, 0)
	notes.append(note)
	add_child(note)
	sort_notes()
	update_notes_width()
	return note as StaticBody2D
	
func add_swipe_note(x: int) -> StaticBody2D:
	filled_cells.append(x)
	var note: StaticBody2D = swipe_note_scene.instantiate()
	note.position = Vector2(x, 0)
	notes.append(note)	
	add_child(note)
	sort_notes()
	update_notes_width()
	return note as StaticBody2D

func add_slanted_note_end(x: float, slanted_data: Dictionary) -> StaticBody2D:
	filled_cells.append(x)
	var slanted_long_note_end: StaticBody2D = note_scene.instantiate()
	slanted_long_note_end.position = Vector2(x, 0)
	slanted_long_note_end.slanted = true
	slanted_long_note_end.slanting_start_track_index = slanted_data.slanting_start_track_index
	slanted_long_note_end.slanting_start_bar_index = slanted_data.slanting_start_bar_index
	slanted_long_note_end.slanting_start_note_index = slanted_data.slanting_start_note_index
	notes.append(slanted_long_note_end)
	add_child(slanted_long_note_end)
	sort_notes()
	return slanted_long_note_end as StaticBody2D

func clear_notes() -> void:
	for note: StaticBody2D in notes:
		remove_child(note)
	notes = []
	filled_cells = []

func set_notes_data(notes_data: Array) -> void:
	for data: Dictionary in notes_data:
		var data_pos: String = data.pos
		var x: float = float(data_pos) / EDITOR_C.CELL_EXPORT_SCALE
		var note: StaticBody2D = add_note(x)
		var data_len: String = data.len
		note.set_width(float(data_len) / EDITOR_C.CELL_EXPORT_SCALE)

func get_notes_data() -> Array:
	var notes_data: Array = []
	for note: StaticBody2D in notes:
		notes_data.append({
			pos = note.position.x * EDITOR_C.CELL_EXPORT_SCALE, 
			len = note.get_width() * EDITOR_C.CELL_EXPORT_SCALE,
			member = note.member,
			layer = note.layer_number,
			slanted = note.slanted,
			swipe = note.is_swipe
			#slanting_start_track_index = note.slanting_start_track_index,
			#slanting_start_bar_index = note.slanting_start_bar_index,
			#slanting_start_note_index = note.slanting_start_node_index
			})
	return notes_data as Array

func sort_notes() -> void:
	for i: int in range(notes.size() - 1, - 1, - 1):
		for j: int in range(1, i + 1, 1):
			if notes[j - 1].position.x > notes[j].position.x:
				var t: StaticBody2D = notes[j - 1]
				notes[j - 1] = notes[j]
				notes[j] = t

func is_cell_empty_at(x: int) -> bool:
	if filled_cells.has(x):
		return false
	for note: StaticBody2D in notes:
		if x >= note.position.x and x < note.position.x + note.get_width():
			return false
	#for ends: StaticBody2D in slanted_long_notes_end:
		#if x >= ends.position.x and x < ends.position.x + ends.get_width():
			#return false
		
	return true

func update_notes_width() -> void:
	for note: StaticBody2D in notes:
		note.max_width = float(calc_note_max_width(note.position.x))

func calc_note_max_width(note_x: float) -> int:
	@warning_ignore("narrowing_conversion")
	var end_note_x: int = note_x + EDITOR_C.CELL_WIDTH
	var max_note_w: float = get_width() - note_x
	for x: int in range(end_note_x, get_width(), EDITOR_C.CELL_WIDTH):
		if filled_cells.has(int(x)):
			print("filled cells has", x)
			max_note_w = x - note_x
			break
	return max_note_w as int

func delete_note(note: StaticBody2D) -> void:
	print("delete note begin", filled_cells)
	filled_cells.erase(int(note.position.x))
	update_notes_width()
	remove_child(note)
	notes.erase(note)
	editor.unset_active_note()
	print("deleted!", filled_cells)

func get_first_note() -> StaticBody2D:
	if notes.size() == 0:
		return null
	var first: StaticBody2D = notes[0]
	for note: StaticBody2D in notes:
		if note.position.x < first.position.x:
			first = note
	return first as StaticBody2D

func get_next_bar() -> Node2D:
	if track.bars.size() > index + 1:
		return track.bars[index + 1]
	else :
		return null

func get_note_after(x_position: int) -> StaticBody2D:
	if notes.size() > 0:
		var next: Array = []
		for note: StaticBody2D in notes:
			if note.position.x > x_position:
				next.append(note)
		if next.size() > 0:
			var first: StaticBody2D = next[0]
			for next_note: StaticBody2D in next:
				if next_note.position.x < first.position.x:
					first = next_note
			return first
	return null

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if hold_shift:
			var note_x: float = event.position.x
			var cell_index: int = floor(note_x / float(EDITOR_C.CELL_WIDTH))
			@warning_ignore("narrowing_conversion")
			if is_cell_empty_at(cell_index * EDITOR_C.CELL_WIDTH):
				print("Swipe note added at cell index:", cell_index)
				print("Note added at cell index:", cell_index)

				# Add the note at the cell index
				@warning_ignore("narrowing_conversion")
				var note: StaticBody2D = add_swipe_note(cell_index * EDITOR_C.CELL_WIDTH)
				
				# Find the index of the note in the filled_cells array
				var note_index: int = filled_cells.find(note.position.x)
				print("filled: ", filled_cells)
				print("Note index in filled_cells:", note_index)

				editor.set_active_note(note)
		else:
			print("Bar " + str(index) + " Clicked at", event.position)

			# Calculate the index of the cell based on the note's x position
			var note_x: float = event.position.x
			var cell_index: int = floor(note_x / float(EDITOR_C.CELL_WIDTH))
			@warning_ignore("narrowing_conversion")
			if is_cell_empty_at(cell_index * EDITOR_C.CELL_WIDTH):
				print("Note added at cell index:", cell_index)

				# Add the note at the cell index
				var note: StaticBody2D = add_note(cell_index * EDITOR_C.CELL_WIDTH)
				
				# Find the index of the note in the filled_cells array
				var note_index: int = filled_cells.find(note.position.x)
				print("filled: ", filled_cells)
				print("Note index in filled_cells:", note_index)

				# Update SLANTED_LONG_NOTE_START and set the active note in the editor
				editor.set_active_note(note)
			else:
				print("Cell is not empty, cannot add note")
		
func on_set_slanting_node_data() -> Dictionary:
	var starting_note: Dictionary = {}
	starting_note.slanting_start_track_index = track_index
	starting_note.slanting_start_bar_index = index
	starting_note.slanting_start_note_index = UTILITIES.SLANTED_LONG_NOTE_START
	
	return starting_note as Dictionary
