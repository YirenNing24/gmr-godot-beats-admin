extends ColorRect

var audio_stream: AudioStream
var audio_preview: Variant

var preview: Variant
var loaded: bool = false

var full_size: Vector2 = Vector2()
var viewport_rect: Rect2 = Rect2()
var last_scroll_val: int = 0
var last_scale_val: int = 1
var updated: bool = true

var preview_len: float
const COLOR: Color = Color("#00ffff")
var step: int = 2

func _process(_delta: float) -> void:
	queue_redraw()

func generate_waveform(stream: AudioStreamOggVorbis) -> void:
	loaded = false
	var preview_generator: AudioStreamPreviewGenerator = AudioStreamPreviewGenerator.new()
	var _connection_id: int = preview_generator.preview_complete.connect(_on_generate_preview_complete)
	audio_preview = preview_generator.generate_preview(stream)

func _on_generate_preview_complete(_generated_preview: Variant) -> void:
	if !loaded:
		loaded = true
		queue_redraw()
		set_process(true)

func set_scroll(value: int) -> void:
	if last_scroll_val != value:
		last_scroll_val = value
		viewport_rect.position = Vector2(value, 0)
		queue_redraw()

func _draw() -> void:
	if audio_preview != null: 
		var rect_size: Vector2 = get_parent().get_size()
		size = rect_size
		var preview_length: Variant = audio_preview.get_length()
		for pixel_x: int in range(0, rect_size.x):
			var offset_start: float = (pixel_x + 1) * preview_length / rect_size.x
			var offset_end: float = (pixel_x + 1) * preview_length / rect_size.x
			var max_value: float = audio_preview.get_max(offset_start, offset_end) * 0.5 + 0.5
			var min_value: float = audio_preview.get_min(offset_start, offset_end) * 0.5 + 0.5
			draw_line(Vector2(pixel_x, min_value * rect_size.y), Vector2(pixel_x + 1, max_value * rect_size.y), Color("ffff39b0"), 1, false)

func update() -> void:
	if not updated:
		updated = true
		queue_redraw()

func set_viewport_rect(rect: Rect2) -> void:
	if viewport_rect.position.x != rect.position.x or viewport_rect.position.y != rect.position.y or viewport_rect.size.x != rect.size.x or viewport_rect.size.y != rect.size.y:
		viewport_rect = rect
		queue_redraw()

func _draw_waveform() -> void:
	var viewport_size: Vector2 = viewport_rect.size
	var viewport_position: Vector2 = viewport_rect.position

	for i: int in range(0, full_size.x, step):
		if i >= viewport_position.x and i < viewport_position.x + viewport_size.x:
			var ofs: float = i * preview_len / full_size.x
			var ofs_n: float = (i + step) * preview_len / full_size.x
			var maximum: float = preview.get_max(ofs, ofs_n) * 0.5 + 0.5
			var minimum: float = preview.get_min(ofs, ofs_n) * 0.5 + 0.5

			draw_line(Vector2(i + 1, viewport_size.y * 0.05 + minimum * viewport_size.y * 0.9), Vector2(i + 1, viewport_size.y * 0.05 + maximum * viewport_size.y * 0.9), COLOR, step, false)
