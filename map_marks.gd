extends Node2D

export var shift: Vector2 = Vector2() setget set_shift
export var wave_range: float = 0 setget set_wave_range
export var wave_source: Vector2 = Vector2() setget set_wave_source
onready var sprite = $sprite
onready var wave = $wave


func set_wave_range(new_wave_range: float):
	wave_range = new_wave_range
	wave.material.set_shader_param("wave_center_range", wave_range * sqrt(2))
	wave.visible = wave_range > 0
	wave.modulate.a = 1 - new_wave_range

func set_wave_source(new_wave_source: Vector2):
	wave_source = new_wave_source
	wave.material.set_shader_param("wave_source", wave_source * 1 / shader_scale)
	
func set_shift(new_shift: Vector2):
	shift = new_shift
	sprite.material.set_shader_param("shift", shift / shader_scale)
	wave.material.set_shader_param("shift", shift / shader_scale)

const shader_scale = 22 * 64 / 2
func pack(value: float) -> float:
	return value / shader_scale / 2 + 0.5
	
func pass_stars_to_marks(ustars):
	var data = []
	for star in ustars:
		var jump_range = star.get_jump_range()
		var scan_range = 0 #star.get_scan_range()
		if jump_range > 0 or scan_range > 0:
			data.append(Color(
				pack(star.position.x), pack(star.position.y), 
				pack(jump_range),  pack(scan_range)
			))
#	print("pass_stars_to_marks: ", data)
#	data = [Color(0, 0.5, 0, 0)]
#	print(data)
#	data = []
	if len(data):
		var texture = ShaderTools.make_texture(data)
		sprite.material.set_shader_param("star_positions", texture)
	sprite.material.set_shader_param("stars_amount", len(data))
