extends Node

signal texture_ready(texture: ImageTexture)
signal generation_progress(normalized_progress: float)

const MAX_FREQUENCY: float = 3000.0 # Maximum frequency captured
const IMAGE_HEIGHT: int = 64

var image_compression: float = 10.0 # How many samples in one pixel
var background_color: Color = Color(0.2, 0.2, 0.4, 0.5)
var foreground_color: Color = Color.SILVER

const SAMPLING_RATE: float = 2.0 * MAX_FREQUENCY
const IMAGE_HEIGHT_FACTOR: float = float(IMAGE_HEIGHT) / 256.0 # Converts sample raw height to pixel
const IMAGE_CENTER_Y: int = int(round(IMAGE_HEIGHT / 2.0))

var is_working : bool = false
var must_abort : bool = false


func generate_preview(stream: AudioStreamOggVorbis, image_max_width: int =  2000) -> void:
	
	print('working babbabbb')
	if not stream:
		print('dito ba???')
		return
	if stream != AudioStreamOggVorbis:
		return # not supported
	if image_max_width <= 0:
		print('dito ba???')
		return # User wasn't remarkably brilliant
	if is_working:
		must_abort = true
		while is_working:
			await get_tree().process_frame
	is_working = true
	
	print('eh pag dito po?!?!?!')
	var data: Array = stream.packet_sequence.packet_data
	var data_size: int = data.size()
	var is_16bit: bool = true
	# For display reasons, lower frequencies than the sampling rate might suffice. 
	# According to the gentlemen of noble steem known as Nyquist and Shannon, 
	# we can sample at SAMPLING_RATE
	var sample_interval: int = 1
	var reduced_data: PackedByteArray = PackedByteArray()
	# We use floor(), not round(), because extra elements in the end of data
	# before next sampling interval are discarded
	var size_data: float = floor(data_size)
	var reduced_data_size: float = int(size_data / float(sample_interval))
	var _data_reduced: int = reduced_data.resize(int(reduced_data_size))
	# For drawing a preview, we use only one byte left channel per sample
	# PCM16 is little endian, so MSB is index 1, not 0
	# reduced_data will contain only that one byte per sample
	var sample_in_i : int = 1 if is_16bit else 0
	var sample_out_i : int = 0
	
	print('eh dito?!?!?!')
	while (sample_in_i < data_size) and (sample_out_i < reduced_data_size):
		reduced_data[sample_out_i] = data[sample_in_i]
		sample_in_i += sample_interval
		sample_out_i += 1
		if must_abort:
			is_working = false
			must_abort = false
			return
	# From now on we work only with reduced_data 
	
	print('working ba?!??!')
	image_compression = ceil(reduced_data_size / float(image_max_width))
	var img_width: int = floor(reduced_data_size/image_compression) # Again floor as we discard remaining samples
	var img: Image = Image.create(img_width, IMAGE_HEIGHT, true, Image.FORMAT_RGBA8)
	img.fill(Color.DARK_SLATE_GRAY)
	var sample_i: int = 0
	var img_x: int = 0
	var final_sample_i: float = (reduced_data_size - image_compression)
	while sample_i < final_sample_i:
		var min_val: int = 128
		var max_val: int = 128
		for block_i: float in range(image_compression):
			var sample_val: int = reduced_data[sample_i]
			# Convert signed bytes to unsigned bytes
			sample_val += 128
			if sample_val >= 256:
				sample_val -= 256
			
			# Get minmax
			if sample_val < min_val:
				min_val = sample_val
			if sample_val > max_val:
				max_val = sample_val
			sample_i += 1
		# Center pixel is always drawn
		if (min_val == 128) and (max_val == 128):
			img.set_pixel(img_x, IMAGE_CENTER_Y, foreground_color)
		else:
			var height_min: int = clamp(
				floor(IMAGE_HEIGHT - (min_val*IMAGE_HEIGHT_FACTOR)),
				0, IMAGE_HEIGHT-1
			)
			var min_height: int = int(height_min)
			var height_max: int = clamp(
				floor(IMAGE_HEIGHT - (max_val*IMAGE_HEIGHT_FACTOR)),
				0, IMAGE_HEIGHT-1
			)
			var max_height: int = int(height_max)
			# min_height and max_height are in audio sample direction (positive up)
			# while img_y is in image direction (positive down)
			var img_y: int = max_height # top value is lower img_y
			while img_y <= min_height: # bottom value is higher img_y
				img.set_pixel(img_x, img_y, foreground_color)
				img_y += 1
		img_x += 1
		if must_abort:
			is_working = false
			must_abort = false
			return
		if (sample_i % 100) == 0:
			var progress: float = sample_i / final_sample_i
			generation_progress.emit(progress)
			await get_tree().process_frame
	is_working = false
	var image_texture: ImageTexture = ImageTexture.create_from_image(img)
	texture_ready.emit(image_texture)
	
