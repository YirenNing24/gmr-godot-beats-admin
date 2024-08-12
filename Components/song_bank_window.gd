extends VBoxContainer

const current_song_scene: PackedScene = preload("res://Components/SongBankComponents/current_song.tscn")

@onready var song_file_dialog: FileDialog = %SongFileDialog
@onready var image_file_dialog: FileDialog = %ImageFileDialog

@onready var uploaded_image: TextureRect = %UploadedImage
@onready var upload_background: TextureRect = %UploadBackground

@onready var music_player_panel: Panel = %MusicPlayerPanel
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var play_button: TextureButton = %PlayButton
@onready var song_slider: HSlider = %SongSlider
@onready var song_title: Label = %SongTitle

@onready var current_song_container: VBoxContainer = %CurrentSongContainer
@onready var audio_stream_player2: AudioStreamPlayer = %AudioStreamPlayer2

var uploaded_ogg_song_buffer: PackedByteArray
var song: AudioStreamOggVorbis

var uploaded_image_buffer: PackedByteArray
var image_buffer: PackedByteArray
var song_name: String

var is_song_slider_dragging: bool = false


func _ready() -> void:
	connect_signal()

func connect_signal() -> void:
	BKMREngine.Song.get_song_images_complete.connect(_on_get_song_images_complete)
	
func _process(_delta: float) -> void:
	if audio_stream_player.playing:
		if not is_song_slider_dragging:
			song_slider.value = audio_stream_player.get_playback_position()
			var elapsed_time: String = time_to_minutes_secs_mili(int(song.get_length() - audio_stream_player.get_playback_position()))
			%TimeLabel.text = "  " + elapsed_time
	if audio_stream_player2.playing:
		var elapsed_time: String = time_to_minutes_secs_mili(int(audio_stream_player2.stream.get_length() - audio_stream_player2.get_playback_position()))
		%TimeLabelCurrent.text = elapsed_time
	
func _on_get_song_images_complete(song_images: Array) -> void:
	for current_song: Dictionary in song_images:
		var current_song_slot: Control = current_song_scene.instantiate()
		current_song_slot.song_slot_data(current_song)
		if !current_song_slot.current_song_playing.is_connected(_on_current_song_play_button_slot_pressed):
			current_song_slot.current_song_playing.connect(_on_current_song_play_button_slot_pressed)
		current_song_container.add_child(current_song_slot)

func _on_current_song_play_button_slot_pressed(song_data: Dictionary) -> void:
	audio_stream_player2.stream = song_data.song
	audio_stream_player2.stop()
	audio_stream_player2.play()
	%SongTitleCurrent.text = song_data.songTitle
	var length_song: float = song_data.song_length
	%TimeLabelCurrent.text = time_to_minutes_secs_mili(length_song)
	
func _on_current_song_play_button_pressed() -> void:
	if audio_stream_player2.stream != null:
		
		if audio_stream_player2.playing:
			audio_stream_player2.stream_paused = true
		else:
			if audio_stream_player2.stream_paused:
				audio_stream_player2.stream_paused = false
			else:
				audio_stream_player2.play()
	
func _on_upload_song_button_pressed() -> void:
	song_file_dialog.visible = true

func _on_image_file_dialog_file_selected(path: String) -> void:
	image_buffer = FileAccess.get_file_as_bytes(path)
	if image_buffer != null:
		uploaded_image_buffer = image_buffer
	var image: Image = Image.new()
	var error: Error = image.load_png_from_buffer(image_buffer)
	if error != OK:
		print("Error loading image", error)
	else:
		var uploaded_pic: Texture =  ImageTexture.create_from_image(image)
		uploaded_image.texture = uploaded_pic
		upload_background.self_modulate = "ffffff00"
		%UploadLabel.visible = false
		
func _on_song_file_dialog_file_selected(path: String) -> void:
	var ogg_song_buffer: PackedByteArray = FileAccess.get_file_as_bytes(path)
	if ogg_song_buffer != null:
		uploaded_ogg_song_buffer = ogg_song_buffer
	song = AudioStreamOggVorbis.load_from_buffer(ogg_song_buffer)
	if song != null:
		initialized_music_player(path)
		
func initialized_music_player(path: String) -> void:
	music_player_panel.visible = true
	audio_stream_player.stream = song
	song_title.text = "  " + path.get_file().get_basename()
	song_slider.max_value = song.get_length()
	music_player_panel.visible = true
	song_name = path.get_file().get_basename()
	%TimeLabel.text = "  " + time_to_minutes_secs_mili(song.get_length())
	
func _on_open_file_dialog_button_pressed() -> void:
	image_file_dialog.visible = true

func _on_play_button_pressed() -> void:
	if audio_stream_player.stream != null:
		
		if audio_stream_player.playing:
			audio_stream_player.stream_paused = true
		else:
			if audio_stream_player.stream_paused:
				audio_stream_player.stream_paused = false
			else:
				audio_stream_player.play()

func _on_song_slider_drag_ended(_value_changed: bool) -> void:
	is_song_slider_dragging = false
	audio_stream_player.play(song_slider.value)

func _on_song_slider_drag_started() -> void:
	is_song_slider_dragging = true
	
func _on_review_button_pressed() -> void:
	on_submit_song_and_image()

func time_to_minutes_secs_mili(time: float) -> String:
	@warning_ignore("narrowing_conversion")
	var mins: int = int(time) / 60.0
	time -= mins * 60
	var secs: int = int(time)
	var mins_str: String = str(mins).pad_zeros(2)
	var secs_str: String = str(secs).pad_zeros(2)
	return mins_str + ":" + secs_str

func on_submit_song_and_image() -> void:
	if song != null and uploaded_image.texture != null:
		var song_and_image: Dictionary = {
			"songBuffer": uploaded_ogg_song_buffer,
			"imageBuffer": image_buffer,
			"songTitle": song_name
		}
		BKMREngine.Song.save_song_and_image(song_and_image)

func _on_visibility_changed() -> void:
	if visible:
		BKMREngine.Song.get_song_images()
