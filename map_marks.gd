extends Node2D

export var shift: Vector2 = Vector2() setget set_shift
onready var sprite = $sprite

func set_shift(new_shift: Vector2):
	shift = new_shift 
	sprite.material.set_shader_param("shift", shift / shader_scale)

const shader_scale = 22 * 64 / 2
func pack(value: float) -> float:
	return value / shader_scale / 2 + 0.5
	
func pass_stars_to_marks(ustars):
	var data = []
	for star in ustars:
		var jump_range = star.get_jump_range()
		var scan_range = star.get_scan_range()
		if jump_range > 0 or scan_range > 0:
			data.append(Color(
				pack(star.position.x), pack(star.position.y), 
				pack(jump_range),  pack(scan_range)
			))
	print("pass_stars_to_marks: ", data)
#	data = [Color(0, 0.5, 0, 0)]
#	print(data)
#	data = []
	var texture = ShaderTools.make_texture(data)
	sprite.material.set_shader_param("star_positions", texture)
	sprite.material.set_shader_param("stars_amount", len(data))
