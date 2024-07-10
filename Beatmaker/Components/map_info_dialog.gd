extends Panel

signal map_info_saved

@onready var beatmap_maker_field: LineEdit = %BeatmapMakerField
@onready var artist_field: LineEdit = $"%ArtistField"
@onready var title_field: LineEdit = $"%TitleField"

const AUDIO_FIELD_NAMES: Array = [
	"TITLE",
	"ARTIST"
]
var audio_info: Dictionary = {}
var audio_file_name: String = ""
var beatmap_maker: String
var session_file_path: String = "user://editor/session"
var session_data: Dictionary = {}

 
func setup(audio_name: String, audio_comments: String) -> void:
	audio_file_name = audio_name
	init_audio_inputs(audio_comments)
	init_map_inputs()

func init_audio_inputs(audio_comments: String) -> void:
	parse_audio_comments(audio_comments)
	if title_field.text == "":
		title_field.text = audio_file_name

func init_map_inputs() -> void:
	session_data = UTILITIES.read_json_file(session_file_path)
	if not session_data:
		session_data = {}
		return 
	beatmap_maker = str(session_data.beatmap_maker)
	beatmap_maker_field.text = beatmap_maker

func parse_audio_comments(audio_comments: String) -> void:
	for characters: String in audio_comments:
		for fields: String in AUDIO_FIELD_NAMES:
			if characters.to_upper().find(str(fields) + "=") != - 1 and characters.split("=").size() > 1:
				var value: String = characters.split("=")[1]
				var node_name: String = fields.to_lower().capitalize()
				var audio_c: VBoxContainer = get_node("VBoxContainer")
				if audio_c.has_node(node_name):
					var n: LineEdit = audio_c.get_node(node_name)
					n.text = value

func apply_map_inputs() -> void:
	beatmap_maker =  beatmap_maker_field.text
	session_data["beatmap_maker"] = beatmap_maker
	UTILITIES.write_json_file(session_file_path, session_data)
	
func set_data(beatmap_maker_data: String, audio_data: Dictionary) -> void:
	beatmap_maker_field.text = str(beatmap_maker_data)
	set_audio_inputs_from(audio_data)
	apply_map_inputs()
	apply_audio_inputs()
	
func set_audio_inputs_from(data: Dictionary) -> void:
	artist_field.text = data["artist"]
	title_field.text= data["title"]
	
	if title_field.get_text() == "":
		title_field.set_text(audio_file_name)
		
func apply_audio_inputs() -> void:
	audio_info["artist"] = artist_field.text
	audio_info["title"] = title_field.text
	
#func _on_confirmed() -> void:

func _on_save_button_pressed() -> void:
	if  beatmap_maker_field.text == "" or title_field.text == "":
		var pos: Vector2 = position
		visible = false
		position = pos
		return
		
	apply_map_inputs()
	apply_audio_inputs()
	map_info_saved.emit()


func _on_cancel_button_pressed() -> void:
	visible = false
