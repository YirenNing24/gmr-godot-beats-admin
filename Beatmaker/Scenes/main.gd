extends Control

signal preview_updated
#signal connecting_slanted_long_note(value: bool)

var track_scene: PackedScene = preload("res://Beatmaker/Components/track.tscn")

@onready var file_menu_button: MenuButton = %FileMenuButton
@onready var file_dialog: FileDialog = %FileDialog
@onready var tracks_container: VBoxContainer = %TracksContainer
@onready var window_scroll: ScrollContainer = %WindowScroll
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var bpm_input: SpinBox = %BPMInput
@onready var waveform_container: Control = %WaveformContainer
@onready var waveform_node: ColorRect = %WaveformNode
@onready var cursor_container: Control = %CursorContainer
@onready var cursor_slider: HSlider = %CursorSlider
@onready var cursor_static: Node2D =  %CursorStatic
@onready var cursor_playback: Node2D = %CursorPlayBack
@onready var map_info_dialog: Panel = %MapInfoDialog
@onready var import_map_dialog: FileDialog = %ImportMap
@onready var set_start_input: SpinBox = %StartPosInput
@onready var play_button: Button = %PlayButton

var ogg_file_path: String
var is_playing: bool = false
var is_follow_playing: bool = false
var window_size: int = 720
var stream: AudioStreamOggVorbis
var popup_active: bool = false

var editor_dir: String
var audio_file_name: String
var audio_load_thread: Thread = Thread.new()
var editor_thread: Thread = Thread.new()
var load_percent: int = 0
var audio_loaded: bool = false

var map_start_pos: int = 0
var track_length: float
var track_speed: float
var track_tempo: int = 130
var map_info_was_saved: bool = false
var pending_export: bool = false

var waveform_length: float
var waveform_scale: int
var tempo_update_timeout: int = 0
var tempo_update_in_process: bool = false

var ui_scale: int
var scale_ratio: float = 1.0
var previous_scale_ratio: int

var bar_size: float
var bars_count: int
var quarter_time_in_sec: float
var sample_duration_in_sec: float

var window_scroll_size: float = 0
var pending_wscroll_update: bool = false
var cursor_slider_pressed: bool = false
var window_scroll_last_val: int = 0
var window_scroll_and_cursor_d: int = 0
var window_scroll_last_pos: int = 0

var tracks: Array = []
var active_note: StaticBody2D

var active_slanted_long_note_end: StaticBody2D
var active_track: Control
var is_connecting: bool = false

# INPUT MACROS
var hold_ctrl: bool  = false


func _ready() -> void:
	load_editor()
	filemenu_button_items()
	
func load_editor() -> void:
	call_deferred('build_editor')
	
func build_editor() -> void:
	load_percent += 100
	filemenu_button_items()
	call_deferred('set_process', true)
	call_deferred('set_process_input', true)
	window_scroll_size = window_scroll.get_minimum_size().x
	update_controls()
	setup_editor_directory()
	update_last_file_path(EDITOR_C.last_file_path)
	
func _process(delta: float) -> void:
	if pending_wscroll_update:
		window_scroll.set_h_scroll(int(window_scroll_size))
		pending_wscroll_update = false
	var window: Window = get_window()	
	tracks_container.custom_minimum_size = Vector2(window.size.x - 200, 260)
	cursor_container.position = Vector2(cursor_container.position.x, window_scroll.get_v_scroll())

	if tempo_update_timeout > 0:
		tempo_update_timeout -= int(delta)
	elif tempo_update_timeout < 0:
		tempo_update_timeout = 0
		tempo_update_in_process = true
		@warning_ignore("narrowing_conversion")
		var old_waveform_length: int = waveform_length
		var cursor_value: int = int(cursor_slider.value)
		var scroll_value: int = window_scroll.get_h_scroll()
		var delta_scroll: int = scroll_value - cursor_value
		set_params()
		redraw_map()
		@warning_ignore("narrowing_conversion")
		var editor_scale: float = waveform_length / old_waveform_length
		cursor_slider.value = cursor_slider.value * editor_scale
		window_scroll.set_h_scroll(int(cursor_slider.value + delta_scroll))

		cursor_static.position = Vector2(cursor_slider.value, cursor_static.position.y)
		tempo_update_in_process = false
		window_scroll_last_val = window_scroll.get_h_scroll()
		
	waveform_node.update()
	if is_playing:
		cursor_playback.position = Vector2(track_speed * audio_stream_player.get_playback_position() * scale_ratio, 0)
	else:
		cursor_playback.position = cursor_static.position

	if is_playing and is_follow_playing:
		if cursor_playback.position.x >= window_scroll.size.x * 0.5:
			@warning_ignore("narrowing_conversion")
			window_scroll.set_h_scroll(cursor_playback.position.x - window_scroll.size.x * 0.5)

func update_last_file_path(file_path: String) -> void:
	EDITOR_C.last_file_path = file_path

func setup_editor_directory() -> void:
	editor_dir = "user://editor"
	if not DirAccess.open(editor_dir):
		var _make_directory: Error = DirAccess.make_dir_absolute(editor_dir)
	
func set_params() -> void:
	sample_duration_in_sec = stream.get_length()
	quarter_time_in_sec = 60.0 / track_tempo
	@warning_ignore("narrowing_conversion")
	var cell_width: int = EDITOR_C.CELL_WIDTH
	var quarters_count: int = EDITOR_C.QUARTERS_COUNT
	var cells_in_quarter_count: int = EDITOR_C.CELLS_IN_QUARTER_COUNT
	bar_size = float(cell_width * quarters_count * cells_in_quarter_count)
	track_speed = bar_size / (quarter_time_in_sec * quarters_count)
	track_length = round(track_speed * sample_duration_in_sec)
	
	bars_count = round(track_length / bar_size)
	
	@warning_ignore("narrowing_conversion")
	waveform_scale = track_length / EDITOR_C.WAVEFORM_W
	waveform_length = track_length

	call_deferred('deferred_set_params')
	cursor_playback.speed = track_speed
	ui_scale = 0
	scale_ratio = 1
	previous_scale_ratio = 1
	scale_to(0)
	
func deferred_set_params() -> void:
	window_scroll.get_h_scroll_bar().modulate = Color(0, 0, 0, 0)
	waveform_container.size = Vector2(waveform_length, EDITOR_C.WAVEFORM_H)
	cursor_slider.max_value = waveform_length
	cursor_slider.custom_minimum_size = Vector2(waveform_length, 16)
	
	
func load_waveform() -> void:
	waveform_node.generate_waveform(stream)

func play() -> void:
	if is_playing:
		is_playing = false
		audio_stream_player.stop()
	else :
		is_playing = true
		unset_active_note()
		unset_active_track()
		var audio_track: float = cursor_slider.value / track_speed
		audio_track = audio_track / scale_ratio
		audio_stream_player.play(audio_track)
		
	play_button.set_playing(is_playing)

func cursor_focus() -> void:
	if is_playing:
		play()
	@warning_ignore("narrowing_conversion")
	window_scroll.set_h_scroll(cursor_static.position.x - EDITOR_C.CURSOR_FOCUS_OFFSET)

func scale_to(dir: float) -> void:
	if pending_wscroll_update:
		return 
	var value: float = dir * (waveform_scale / 10.0)
	@warning_ignore("narrowing_conversion")
	ui_scale += value
	var curr_scale: float = waveform_scale + ui_scale
	scale_ratio = curr_scale / waveform_scale
	if scale_ratio <= 0 or str(scale_ratio) == "0":
		scale_ratio = 0.1
		@warning_ignore("narrowing_conversion")
		ui_scale -= value
		return 
	call_deferred('deferred_scale_to')

func deferred_scale_to() -> void:
	var scale_d: float = scale_ratio / previous_scale_ratio
	var cursor_value: float = cursor_slider.value
	var scroll_value: float = window_scroll.get_h_scroll()
	var d: float = cursor_value - scroll_value
	cursor_slider.max_value = waveform_length * scale_ratio
	cursor_slider.custom_minimum_size = Vector2(waveform_length * scale_ratio, 100)
	cursor_slider.value = cursor_value * scale_d
	var scaled_size: Vector2 = Vector2((waveform_length * 1), EDITOR_C.WAVEFORM_H)
	waveform_container.custom_minimum_size = scaled_size
	waveform_container.size = scaled_size
	cursor_playback.speed_scale = scale_ratio
	window_scroll_size = cursor_slider.value - d
	pending_wscroll_update = true
	for track: Control in tracks:
		track.update_scale(scale_ratio)
	@warning_ignore("narrowing_conversion")
	previous_scale_ratio = scale_ratio

func _on_cursor_slider_value_changed(value: float) -> void:
	if tempo_update_in_process:
		return 
	cursor_static.position = Vector2(value, cursor_static.position.y)
	if is_playing:
		var audio_track_time: float = cursor_slider.value / track_speed
		audio_track_time = audio_track_time / scale_ratio
		audio_stream_player.play(audio_track_time)

func _on_bpm_input_tempo_changed(value: float) -> void:
	if track_tempo != bpm_input.value:
		@warning_ignore("narrowing_conversion")
		track_tempo = bpm_input.value
		@warning_ignore("narrowing_conversion")
		tempo_update_timeout = 1.0
		print("tempo updated to", track_tempo)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_hold_ctrl'):
		hold_ctrl = true
		print('hold_ctrl: ', hold_ctrl)
	elif event.is_action_released('ui_hold_ctrl'):
		hold_ctrl = false
		print('hold_ctrl: ', hold_ctrl)
		
func _on_window_scroll_minimum_size_changed() -> void:
	var d: float = cursor_slider.value - window_scroll.get_h_scroll()
	if d > window_size and not pending_wscroll_update:
		window_scroll_size = window_scroll.get_h_scroll() + d
		pending_wscroll_update = true

func _on_window_scroll_resized() -> void:
	pass # Replace with function body.

func filemenu_button_items() -> void:
	var popup: PopupMenu = file_menu_button.get_popup()
	if not popup.index_pressed.is_connected(_on_filemenu_button_index_pressed):
		var _connect: int = popup.index_pressed.connect(_on_filemenu_button_index_pressed)
	popup.add_item('Import Song', 0)
	popup.add_item('Import Beatmap File', 1)
	popup.add_separator()
	popup.add_item('Open Song From Database', 2)
	popup.add_item('Open Beatmap File From Database', 3)
	popup.add_separator()
	popup.add_item('Save Beatmap Locally', 4)
	popup.add_item('Export Beatmap to Database', 5)
	popup.add_separator()
	popup.add_item('Reset', 6)
	popup.add_item('Exit', 7)
	
	disabled_app_bar_items()
	
func disabled_app_bar_items() -> void:
	var popup: PopupMenu = file_menu_button.get_popup()
	popup.set_item_disabled(4, true)
	popup.set_item_disabled(5, true)

func _on_filemenu_button_index_pressed(index: int) -> void:
	if index == 0:
		import_audio()
	
	elif index == 6:
		map_info_dialog.visible = true
	elif index == 7:
		var _reset: Error = get_tree().change_scene_to_file('res://Scenes/main.tscn')

func _on_map_info_dialog_map_info_saved() -> void:
	map_info_was_saved = true
	export_data()

func import_audio() -> void:
	file_dialog.visible = true

	file_dialog.current_file = ""
	file_dialog.popup_centered()
	preview_updated.emit()

func update_load_audio(_text: String) -> void:
	#if add_map_button.disabled:
		#add_map_button.set_text(text)
	pass

func _on_import_map_file_selected(path: String) -> void:
	import_data(path)

func _on_file_dialog_file_selected(path: String) -> void:
	var _start_thread: Error = audio_load_thread.start(load_song.bind(path))

func check_audio() -> bool:
	var checker: bool = FileAccess.file_exists(ogg_file_path)
	if not checker:
		print("file not found")
#		show_notice(ogg_file_path + ("file not found"))
		return false
	return true

func is_song_loaded(audio_data: AudioStreamOggVorbis) -> bool:
	if audio_data == null:
#		show_notice("error")
		audio_load_thread.wait_to_finish()
		return false
	else:
		return true
		
func load_ogg(path: String) -> AudioStreamOggVorbis:
	var ogg_file: AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_file(path)
	return ogg_file as AudioStreamOggVorbis
	
func load_song(input_file_path: String) -> void:
	print("Loading started ", input_file_path)
	enable_load_song(false)
	update_load_audio(tr("Loading..."))
	var is_copied: bool = copy_song(input_file_path)
	if not is_copied:
		audio_load_thread.wait_to_finish()
		enable_load_song(true)
		return 
	if not check_audio():
		audio_load_thread.wait_to_finish()
		enable_load_song(true)
		return 
	update_load_audio(tr("Loading.."))
	stream =  load_ogg(ogg_file_path)
	print("FILE:", ogg_file_path, stream)
	if not is_song_loaded(stream):
		return
	call_deferred('set_audio_player_stream', stream)
	update_load_audio(tr("Loading..."))
	load_waveform()
	set_params()
	audio_loaded = true
	update_controls()
	update_last_file_path(input_file_path)
	update_load_audio(tr("Audio Loaded"))

func set_audio_player_stream(audio_stream: AudioStreamOggVorbis) -> void:
	audio_stream_player.stream = audio_stream

func update_controls() -> void:
	if audio_loaded:
		#add_song_button.set_disabled(true)
		play_button.set_disabled(false)
		#import_map_button.set_disabled(false)
		#save_map_button.set_disabled(false)
		#zoom_in_button.set_disabled(false)
		#zoom_out_button.set_disabled(false)
		#bpm_input.set_disabled(false)
		call_deferred('add_track')
		#window_scroll.show()
		#$"%AddMemberContainer".show()
		#
	elif not audio_loaded:
		play_button.set_disabled(true)
		#import_map_button.set_disabled(true)
		#save_map_button.set_disabled(true)
		#zoom_in_button.set_disabled(true)
		#zoom_out_button.set_disabled(true)
		#bpm_input.set_disabled(true)
		#visualizer_container.hide()
		#window_scroll.hide()
		#$"%AddMemberContainer".hide()

func _on_play_button_pressed() -> void:
	play()

func _on_audio_stream_player_finished() -> void:
	if is_playing:
		play()

func update_cursor_length() -> void:
	var offset: int = 0
	for t: Control in tracks:
		@warning_ignore("narrowing_conversion")
		offset += t.custom_minimum_size.y
	cursor_static.set_length_offset(offset)
	cursor_playback.set_length_offset(offset)

func add_track() -> void:
	%AppBar.show()
	for i: int in 5:
		var track: Control = track_scene.instantiate()
		track.set_info()
	
		track.setup(bars_count)
		track.track_index = i
		track.position = Vector2(0, (tracks.size() + 1) * (EDITOR_C.CELL_HEIGHT + EDITOR_C.TRACK_DISTANCE))
		track.set_start_position(map_start_pos)
		tracks_container.call_deferred('add_child', track)
		tracks.append(track)
		set_active_track(track)
		update_cursor_length()
		scale_to(0)

func _on_start_pos_input_changed_value(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	map_start_pos = value
	for track: Control in tracks:
		track.set_start_position(map_start_pos)

func set_active_track(track: Control) -> void:
	if active_track != null:
		active_track.set_active(false)
	active_track = track
	active_track.set_active(true)

func unset_active_track() -> void:
	if active_track != null:
		active_track.set_active(false)
	active_track = null

func set_active_note(note: StaticBody2D) -> void:
	if active_note != null:
		active_note.set_active(false)
	active_note = note
	active_note.set_active(true)
	var note_bar_track: Control = note.bar.track
	set_active_track(note_bar_track)
	
func unset_active_note() -> void:
	if active_note != null:
		active_note.set_active(false)
	active_note = null

func _on_connecting_slanted_long_note(value: bool) -> void:
	is_connecting = value
	print(is_connecting, ' is connecting')
		
func set_active_slanted_long_note_end(slanted_long_note_end: StaticBody2D) -> void:
	if hold_ctrl and is_connecting:
		if active_slanted_long_note_end != null:
			active_slanted_long_note_end.set_active(false)
		active_slanted_long_note_end = slanted_long_note_end
		active_slanted_long_note_end.set_active(true)
		var note_bar_track: Control = active_slanted_long_note_end.bar.track
		set_active_track(note_bar_track)

func redraw_map() -> void:
	for track: Control in tracks:
		track.setup(bars_count, true)

func copy_song(input_file_path: String) -> bool:
	print("Copy started ", input_file_path)
	var file_name: String = input_file_path.get_file()
	var file_format: String = file_name.get_extension().to_lower()
	ogg_file_path = editor_dir + "/" + "audio" + ".ogg"
	if file_format == "ogg":
		var dir: DirAccess = DirAccess.open(editor_dir)
		if dir:
			var _dir_copy_song: Error = dir.copy(input_file_path, ogg_file_path)
	else :
		#show_alert(str(file_format) + ("File not supported"))
		return false
	print("Copy finished")
	return true as bool

func export_data() -> void:
	var songs_dir: String = "Songs"
	var song_folder: String
	var new_dir: String
	var dir: DirAccess = DirAccess.open(songs_dir)
	print("current dir: ", dir.get_current_dir())
	print("OPEN RETURN CODE: " + str(dir))
	
	var rand_int: int
	randomize()
	rand_int = randi()
	song_folder = str(rand_int) + " " + map_info_dialog.audio_info.artist + "-" + map_info_dialog.audio_info.title 
	print(song_folder)
	var _dir_make: Error = dir.make_dir(song_folder)
	
	new_dir = songs_dir + "/" + song_folder
	var final_song_folder: String = new_dir
	var dir_new: DirAccess = DirAccess.open(new_dir)
	
	var tracks_data: Array = []
	for track: Control in tracks:
		tracks_data.append(track.get_data())
	
	var data: Dictionary = {
		audio = map_info_dialog.audio_info, 
		beatmap_maker = map_info_dialog.beatmap_maker, 
		audio_file = map_info_dialog.audio_info.artist + "-" + map_info_dialog.audio_info.title + ".ogg",
		date = get_curr_date(), 
		tempo = track_tempo, 
		song_folder = final_song_folder,
		start_pos = map_start_pos * EDITOR_C.CELL_EXPORT_SCALE, 
		tracks = tracks_data, 
	}
	new_dir += "/" + "map-" + map_info_dialog.audio_info.artist + "-" + map_info_dialog.audio_info.title + ".json"
	UTILITIES.write_json_file(new_dir, data)
	update_last_file_path(new_dir)
	new_dir = songs_dir + "/" + song_folder
	new_dir += "/" +map_info_dialog.audio_info.artist + "-" + map_info_dialog.audio_info.title + ".ogg"
	
	var file_name: String = "editor_dir/audio.ogg"
	var file_format: String = str(file_name.get_extension()).to_lower()
	ogg_file_path = editor_dir + "/" + "audio" + ".ogg"
	
	if file_format == "ogg":
		var _copy_directoty: Error = dir_new.copy(ogg_file_path, new_dir)
		var error: Error = DirAccess.get_open_error()
		print(error)
	else :
		#show_notice(str(file_format) + ("not accepted"))
		return
		
	#show_notice("Map Saved Successfully")

func get_curr_date() -> String:
	var today: Dictionary = Time.get_datetime_dict_from_system()
	return ("%s-%02d-%02d" % [today.year, today.month, today.day]) as String

#func grab_cursor_slider_focus(_e):
	#return 

func enable_load_song(enabled: bool) -> void:
	if enabled:
		pass
		#add_map_button.set_text("Load Audio")
		#add_map_button.disabled = false
	else:
		pass
		#add_map_button.set_text("Loading")
		#add_map_button.disabled = true
		
func import_data(path: String) -> void:
	var data: Dictionary = UTILITIES.read_json_file(path)
	if data == null:
		return
	var data_tempo: String = data.tempo
	track_tempo = int(data_tempo)
	bpm_input.set_tempo(track_tempo)
	var data_start_positon: String = data.start.pos
	@warning_ignore("narrowing_conversion")
	map_start_pos = float(data_start_positon) / EDITOR_C.CELL_EXPORT_SCALE
	set_start_input.input.set_value(map_start_pos)
	map_info_dialog.set_data(data.creator, data.audio)
	map_info_was_saved = false
	pending_export = false
	clear_tracks()
	set_params()
	scale_to(0)
	@warning_ignore("narrowing_conversion")
	var y: int = EDITOR_C.CELL_HEIGHT + EDITOR_C.TRACK_DISTANCE
	for track_data: Dictionary in data.tracks:
		var t: Control = track_scene.instance()
		t.set_data(track_data)
		t.set_position(Vector2(0, y))
		t.set_start_position(map_start_pos)
		tracks_container.add_child(t)
		tracks.append(t)
		y += t.get_height()
	update_cursor_length()
	update_last_file_path(path)
	print("data imported")
	print("new track data:", tracks)

func destroy_track(track: Control) -> void:
	if active_track == track:
		active_track = null
	tracks_container.remove_child(track)
	tracks.erase(track)
	update_cursor_length()
	
func clear_tracks() -> void:
	var tracksize: int = tracks.size()
	for t: int in tracksize:
		print("track ", t ," removed")
		print("track ", tracks[0] ," removed")
		var first_track: Control = tracks[0]
		destroy_track(first_track)
 # Replace with function body.
