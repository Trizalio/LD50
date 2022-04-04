extends Node2D

#var Planet = preload('res://planet.gd')
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var PlanetButton = preload('res://planet_button.tscn')

#const zoom_zero_shift: Vector2 = Vector2(0, 0)
const zoom_zero_shift: Vector2 = Vector2(700, 450)
const zoom_shift: Vector2 = Vector2(500, 475)
const zoom_shift2: Vector2 = Vector2(-200, 25)
#const zoom_shift: Vector2 = Vector2(500, 475)
const zoom_scale: float = 4.0
const zoom_duration: float = 0.8
const zoom_trans = Tween.TRANS_SINE
const zoom_ease = Tween.EASE_IN_OUT
const button_outer_x: float = 500.0
var current_planet = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	var planet = Planet.new()
#	add_planet(planet)
	pass # Replace with function body.
	
func load_universe(stars: Array):
	print('load_universe: ', stars)
	for star in stars:
		add_planet(star)
	
func load_system(star, planets: Array):
	print('load_system: ', star, ', planets:', planets)
	add_planet(star)
	for planet in planets:
		add_planet(planet)

func add_planet(planet: Planet):
	var root = $base/root
	root.add_child(planet)
	planet.connect("pressed", self, 'planet_pressed', [planet])

func remove_buttons():
	var buttons_node = $buttons
	for button in buttons_node.get_children():
		var target_position = Vector2(button_outer_x, button.rect_position.y)
		Animator.animate(button, 'rect_position', target_position, zoom_duration, zoom_trans, zoom_ease)
		Animator.animate(button, 'modulate', Color(1, 1, 1, 0), zoom_duration, zoom_trans, zoom_ease, true)
	
const delay_per_button = 0.1
const x_shift_per_button_per_height = 0.5
func add_buttons(button_texts: Array):
	var buttons_node = $buttons
	var height_per_button = 170 - len(button_texts) * 10
	var start_height: float = -height_per_button * len(button_texts) / 2.0
	var curve_center: float = len(button_texts) / 2.0 - 0.5
	for i in len(button_texts):
		var text = button_texts[i]
		var new_button = PlanetButton.instance()
		new_button.text = text
		new_button.modulate = Color(1, 1, 1, 0)
		new_button.rect_position.y = start_height + height_per_button * i
		new_button.rect_position.x = button_outer_x
		new_button.connect("pressed", self, 'button_pressed', [text])
		buttons_node.add_child(new_button)
		var target_x = -x_shift_per_button_per_height * abs(i - curve_center) * height_per_button
		var target_position = Vector2(target_x, new_button.rect_position.y)
		var duration = zoom_duration + delay_per_button * i
		Animator.animate(new_button, 'rect_position', target_position, duration, zoom_trans, zoom_ease)
		Animator.animate(new_button, 'modulate', Color(1, 1, 1, 1), duration, zoom_trans, zoom_ease)

func button_pressed(text: String):
	GameState.button_pressed(current_planet, text)
	remove_buttons()
#	print(text)
#	planet_pressed(current_planet)
#	zoom_camera(0.0001)

func zoom_camera(zoom: float, point: Vector2 = Vector2(0, 0), duration = null):
	if duration == null:
		duration = zoom_duration
	
	var root = $base/root
	if duration == 0:
		root.position = point
		root.scale = Vector2(zoom, zoom)
	else:
		Animator.animate(root, 'position', point, duration, zoom_trans, zoom_ease)
		Animator.animate(root, 'scale', Vector2(zoom, zoom), duration, zoom_trans, zoom_ease)

var texts = []
func planet_pressed(planet):
	if current_planet != planet:
		move_camera_to_planet(planet)
		texts += ['some']
		add_buttons(texts)
#		add_buttons(["test", 'other', 'third'])
	else:
		recall_camera()
		remove_buttons()
	
func move_camera_to_planet(planet, target_zoom_scale = null):
	if target_zoom_scale == null:
		target_zoom_scale = zoom_scale
	current_planet = planet
	var camera_center_position = zoom_shift2 - planet.position * target_zoom_scale
	zoom_camera(target_zoom_scale, camera_center_position)
	
func recall_camera():
	current_planet = null
	zoom_camera(1)
