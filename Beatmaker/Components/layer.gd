extends ScrollContainer

signal generation_progress(normalized_progress: float)
signal generation_completed

@onready var waveform_node: TextureRect = %WaveformNode
@onready var waveform_container: Control = %WaveformContainer
@onready var cursor_container: Control = %CursorContainer
@onready var cursor_slider: HSlider = %CursorSlider
@onready var cursor_playback: Node2D = %CursorPlayBack
@onready var cursor_static: Node2D = %CursorStatic
@onready var tracks_container: VBoxContainer = %TracksContainer

var waveform_generator: Node = preload("res://Beatmaker/Components/WaveformGenerator.tscn").instantiate()
var is_playing: bool = false
var is_follow_playing: bool = false
var window_scroll_size: float = 0
var pending_wscroll_update: bool = false
var cursor_slider_pressedc: bool = false
var window_scroll_last_value: int = 0
var window_scroll_and_cursor_d: int = 0
var window_scroll_last_position: int = 0
var active_track: Control
var tracks: Array = []
var ui_scale: float
var scale_ratio: float
var previous_scale_ratio: float
var bar_size: float
var bars_count: float
var quarter_time_in_seconds: float
var sample_duration_in_seconds: float
var stream: AudioStreamOggVorbis
var map_start_pos: int = 0
var track_length: int
var track_speed: int
var track_tempo: int = 130
var map_info_was_saved:  bool = false
var pending_export: bool = false
var hold_ctrl: bool
var waveform_length: int
var waveform_scale: int
var tempo_update_timeout: int = 0
var tempo_update_in_process: bool = false
var track_scene: PackedScene = preload("res://Beatmaker/Components/track.tscn")


func _ready() -> void:
	add_child(waveform_generator)
	waveform_generator.generation_progress.connect(_on_generation_progress)
	waveform_generator.texture_ready.connect(_on_texture_ready)
	#load_waveform()
	
func _on_generation_progress(normalized_progress: float) -> void:
	generation_progress.emit(normalized_progress)

func _on_texture_ready(_image_texture: ImageTexture) -> void:
	#texture = image_texture
	generation_completed.emit()
	
#func _process(delta: float) -> void:
	#if pending_wscroll_update:
		#set_h_scroll(window_scroll_size)
		#pending_wscroll_update = false
	#tracks_container.set_custom_minimum_size(Vector2(DisplayServer.screen_get_size().x - 200, 100))
	#cursor_container.set_position(Vector2(cursor_container.get_position().x, get_v_scroll()))
	#if tempo_update_timeout > 0:
		#tempo_update_timeout -= delta
	#elif tempo_update_timeout < 0:
		#tempo_update_timeout = 0
		#tempo_update_in_process = true
		#var old_waveform_length: int = waveform_length
		#var cursor_value: int = int(cursor_slider.get_value())
		#var scroll_value: int = get_h_scroll()
		#var dd: int = scroll_value - cursor_value
		#set_params()
		#redraw_map()
		#var self_scale: float = (waveform_length / old_waveform_length)
		#cursor_slider.set_value(cursor_slider.get_value() * self_scale)
		#set_h_scroll(cursor_slider.get_value() + dd)
		#cursor_static.set_position(Vector2(cursor_slider.get_value(), cursor_static.get_position().y))
		#tempo_update_in_process = false
	#window_scroll_last_value = get_h_scroll()
	#waveform_node.set_scroll(window_scroll_last_value)
	#waveform_node.update()
#
	#if is_playing:
		#cursor_playback.set_position(Vector2(track_speed * stream_player.get_playback_position() * scale_ratio, 0))
	#else :
		#cursor_playback.set_position(cursor_static.get_position())
#
	#if is_playing and is_follow_playing:
		#if cursor_playback.get_position().x >= get_size().x * 0.5:
			#set_h_scroll((int(cursor_playback.get_position().x) - int(get_size().x * 0.5)))
	
func set_params() -> void:
	sample_duration_in_seconds = stream.get_length()
	quarter_time_in_seconds = 60.0 / track_tempo
	bar_size = float(EDITOR_C.CELL_WIDTH * EDITOR_C.QUARTERS_COUNT * EDITOR_C.CELLS_IN_QUARTER_COUNT)
	track_speed = bar_size / (quarter_time_in_seconds * EDITOR_C.QUARTERS_COUNT)
	track_length = round(track_speed * sample_duration_in_seconds)
	bars_count = round(track_length / bar_size)
	waveform_scale = track_length / float(EDITOR_C.WAVEFORM_W)
	waveform_length = track_length
	cursor_playback.speed = track_speed
	waveform_container.set_size(Vector2(waveform_length, EDITOR_C.WAVEFORM_H))
	waveform_node.set_full_size(waveform_container.get_size())
	waveform_node.set_viewport_rect(Rect2(Vector2(), Vector2(get_size().x, EDITOR_C.WAVEFORM_H)))
	waveform_node.set_custom_minimum_size(waveform_container.get_size())
	cursor_slider.set_max(waveform_length)
	cursor_slider.set_custom_minimum_size(Vector2(waveform_length, 16))
	ui_scale = 0
	scale_ratio = 1
	previous_scale_ratio = 1
	scale_to(0)
	
func scale_to(dir: float) -> void:
	if pending_wscroll_update:
		return 
	var value: float = dir * (waveform_scale / 10.0)
	ui_scale += value
	var curr_scale: float = waveform_scale + ui_scale
	scale_ratio = curr_scale / waveform_scale
	if scale_ratio <= 0 or str(scale_ratio) == "0":
		scale_ratio = 0.1
		ui_scale -= value
		return 
	var scale_d: float = scale_ratio / previous_scale_ratio
	var cursor_val: float = cursor_slider.get_value()
	var scroll_val: float = get_h_scroll()
	var d: float = cursor_val - scroll_val
	cursor_slider.set_max(waveform_length * scale_ratio)
	cursor_slider.set_custom_minimum_size(Vector2(waveform_length * scale_ratio, 100))
	cursor_slider.set_value(cursor_val * scale_d)
	var scaled_size: Vector2 = Vector2(waveform_length * scale_ratio, EDITOR_C.WAVEFORM_H)
	waveform_container.set_custom_minimum_size(scaled_size)
	waveform_container.set_size(scaled_size)
	waveform_node.set_custom_minimum_size(scaled_size)
	waveform_node.set_size(scaled_size)
	waveform_node.set_full_size(scaled_size)
	waveform_node.set_scale_ratio(scale_ratio)
	cursor_playback.speed_scale = scale_ratio
	window_scroll_size = cursor_slider.get_value() - d
	pending_wscroll_update = true
	for track: Control in tracks:
		track.update_scale(scale_ratio)
	previous_scale_ratio = scale_ratio

func redraw_map() -> void:
	for t: Node in tracks:
		t.setup(bars_count, true)
		
func load_waveform() -> void:
	waveform_node.set_stream(stream)

func _on_main_stream_data(stream_data: AudioStreamOggVorbis) -> void:
	stream = stream_data

func add_track() -> void:
	for i: int in 5:
		var track: Control = track_scene.instantiate()
		track.set_info()
		track.setup(bars_count)
		track.set_position(Vector2(0, tracks.size() + 1 * (EDITOR_C.CELL_HEIGHT + EDITOR_C.TRACK_DISTANCE)))
		track.set_start_position(map_start_pos)
		tracks_container.call_deferred("add_child", track)
		tracks.append(track)
		set_active_track(track)
		update_cursor_length()
		scale_to(0)

func set_active_track(track: Control) -> void:
	if active_track != null:
		active_track.set_active(false)
	active_track = track
	active_track.set_active(true)
	
func update_cursor_length() -> void:
	var offset: int = 0
	for track: Control in tracks:
		offset += track.get_custom_minimum_size().y
	cursor_static.set_length_offset(offset)
	cursor_playback.set_length_offset(offset)
	
func clear_tracks() -> void:
	var tracksize: int = tracks.size()
	for t: int in tracksize:
		print("track ", t ," removed")
		print("track ", tracks[0] ," removed")
		var tracks_first: Control = tracks[0]
		destroy_track(tracks_first)
		
func destroy_track(track: Control) -> void:
	if active_track == track:
		active_track = null
	tracks_container.remove_child(track)
	tracks.erase(track)
	update_cursor_length()
