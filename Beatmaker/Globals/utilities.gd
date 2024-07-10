extends Node

func read_json_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		print("File not found!", file_path)
		return {} as Dictionary
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("File openning error!", file_path)
		return {} as Dictionary
	var content: String = file.get_as_text()
	var json: Dictionary = JSON.parse_string(content)
	if not json:
		print("File JSON parse error!", file_path)
		return {} as Dictionary
	return json as Dictionary
	
func write_json_file(file_path: String, data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		print("File cant be opened to write", file_path)
		return 
		
	file.store_line(JSON.stringify(data))
	file.close()
