extends Control

signal current_song_playing(song: Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#export interface SongData {
	#songBuffer: string;
	#imageBuffer: string;
	#songTitle: string;
	#uploader?: string;
	#beatMap?: string;
	#timestamp?: number;
#}
func song_slot_data(song_data: Dictionary) -> void:
	var song_buffer: String = song_data.songBuffer
	var song_and_length: Dictionary = buffer_to_ogg(song_buffer)
	song_and_length.songTitle = song_data.songTitle
	%SongTitleCurrent.text = song_data.songTitle
	var song_and_length_length: float = song_and_length.song_length
	%TimeLabelCurrent.text = time_to_minutes_secs_mili(song_and_length_length)
	
	if !%CurrentSongPlayButton.pressed.is_connected(_on_current_song_play_button_pressed):
		%CurrentSongPlayButton.pressed.connect(_on_current_song_play_button_pressed.bind(song_and_length))
	
func _on_current_song_play_button_pressed(song_data: Dictionary) -> void:
	current_song_playing.emit(song_data)
	
func buffer_to_ogg(ogg_buffer_string: String) -> Dictionary:
	var ogg_song_buffer: PackedByteArray = JSON.parse_string(ogg_buffer_string)
	var song: AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_buffer(ogg_song_buffer)
	var song_length: float = song.get_length()
	
	return { "song": song, "song_length": song_length  }
	
func time_to_minutes_secs_mili(time: float) -> String:
	@warning_ignore("narrowing_conversion")
	var mins: int = int(time) / 60.0
	time -= mins * 60
	var secs: int = int(time)
	var mins_str: String = str(mins).pad_zeros(2)
	var secs_str: String = str(secs).pad_zeros(2)
	return mins_str + ":" + secs_str
