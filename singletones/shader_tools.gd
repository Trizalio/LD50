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
