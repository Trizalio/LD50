extends Node


func make_texture(colors: Array): # "colors" is array of Color objects
	var img = Image.new()
	img.create(len(colors), 1, false, Image.FORMAT_RGBAF)
	img.lock()
	for i in range(len(colors)):
		img.set_pixel(i, 0, colors[i])
	img.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex
	
func make_texture2(arrays: Array): # "arrays" is array of arrays of Color objects
	var img = Image.new()
	var width = 0
	for arr in arrays:
		width = max(width, len(arr))
	img.create(len(arrays), width, false, Image.FORMAT_RGBAF)
	img.lock()
	for i in range(len(arrays)):
		var arr = arrays[i]
		for j in range(len(arr)):
			var c = arr[j]
			img.set_pixel(i, j, c)
	img.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex
