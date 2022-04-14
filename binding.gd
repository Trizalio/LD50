extends Node2D

export var shift: Vector2 = Vector2() setget set_shift
export var start_position: Vector2 = Vector2() setget set_start_position
export var end_position: Vector2 = Vector2() setget set_end_position
const bad_color: Color = Color.red
const neutral_color: Color = Color.yellow
const good_color: Color = Color.green
export var color: Color = neutral_color setget set_color
onready var sprite = $sprite

func set_color(new_color: Color):
	if color != new_color:
		color = new_color
		sprite.material.set_shader_param("bindning_color", color)

func use_bad_color():
	set_color(bad_color)
func use_neutral_color():
	set_color(neutral_color)
func use_good_color():
	set_color(good_color)
	
func set_shift(new_shift: Vector2):
	shift = new_shift 
	sprite.material.set_shader_param("shift", shift / shader_scale / 2)

const shader_scale = 22 * 64 / 2
func pack_vector2(value: Vector2) -> Vector2:
	return value / shader_scale / 2

func set_start_position(new_start_position: Vector2):
	start_position = new_start_position
	sprite.material.set_shader_param("start_position", pack_vector2(start_position))

func set_end_position(new_end_position: Vector2):
	end_position = new_end_position
	sprite.material.set_shader_param("end_position", pack_vector2(end_position))

func _ready():
	use_neutral_color()
