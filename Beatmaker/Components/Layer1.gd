extends ScrollContainer

var track_scene: PackedScene = preload("res://Components/track.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_h_scroll_bar().modulate = Color(0, 0, 0, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
