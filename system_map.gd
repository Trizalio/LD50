extends Node2D

#var Planet = preload('res://planet.gd')
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const zoom_shift: Vector2 = Vector2(500, 475)
const zoom_scale: float = 4.0
const zoom_duration: float = 0.8
const zoom_trans = Tween.TRANS_SINE
const zoom_ease = Tween.EASE_IN_OUT
var current_planet = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	var planet = Planet.new()
#	add_planet(planet)
	pass # Replace with function body.
	
func load_system(star, planets: Array):
	add_planet(star)
	for planet in planets:
		add_planet(planet)

func add_planet(planet: Planet):
	var root = $root
	root.add_child(planet)
	planet.connect("pressed", self, 'move_camera_to_planet', [planet])

func move_camera_to_point_with_zoom(point: Vector2, zoom: float):
	var root = $root
	Animator.animate(root, 'position', point, zoom_duration, zoom_trans, zoom_ease)
	Animator.animate(root, 'scale', Vector2(zoom, zoom), zoom_duration, zoom_trans, zoom_ease)

func move_camera_to_planet(planet):
	if current_planet == planet:
		recall_camera()
		return 
	
	current_planet = planet
#	var camera = $root/camera
	var root = $root
	move_camera_to_point_with_zoom(zoom_shift - planet.position * zoom_scale, zoom_scale)
#	root.scale = Vector2(zoom_scale, zoom_scale)
#	root.position = 
#	Animator.animate(root, 'position', Vector2(700, 450), zoom_duration, zoom_trans, zoom_ease)
#	Animator.animate(root, 'scale', Vector2(zoom_scale, zoom_scale), zoom_duration, zoom_trans, zoom_ease)
#	camera.position = planet.position
#	camera.zoom = Vector2(0.2, 0.2)
#	Animator.animate(camera, 'position', planet.position + camera_shift, zoom_duration, 
#		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#	Animator.animate(camera, 'zoom', Vector2(0.2, 0.2), zoom_duration, 
#		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	
func recall_camera():
	current_planet = null
#	var camera = $root/camera
	var root = $root
	move_camera_to_point_with_zoom(Vector2(700, 450), 1)
#	root.scale = Vector2(1, 1)
#	root.position = Vector2(700, 450)
#	Animator.animate(root, 'position', Vector2(700, 450), zoom_duration, zoom_trans, zoom_ease)
#	Animator.animate(root, 'scale', Vector2(1, 1), zoom_duration, zoom_trans, zoom_ease)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
