extends Button

var playing: bool = false


func _ready() -> void:
	set_playing(false)

func set_playing(value: bool) -> void:
	playing = value
	if playing == false:
		text = 'Play'
	else :
		text = 'Playing'
