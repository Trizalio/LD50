extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var game = null

func register_game(game):
	self.game = game

func button_pressed(object, action: String):
	if object == null:
		print('wild button pressed')
		return
	if object.is_ustar:
		if action == 'View':
			game.descend_into_star(object)
		if action == 'Back':
			game.recall_universe_camera()
	else:
		if action == 'Back':
			game.recall_system_camera()
#		else:
#			game.ascend_to_universe()

func get_actions_for_object(object):
	if object.is_ustar:
		return ["View", "Back"]
		
#	if object.is_star:
	return ["Back"]

func get_hint_for_object(object) -> String:
	var result = ''
	if object.is_ustar or object.is_star:
		result = 'Star'
		
	if object.is_planet:
		result = 'Planet'
		
	return '[center]' + result + '[/center]'

func get_hint_for_object_action(object, action: String):
	if object.is_ustar:
		if action == 'View':
			return 'Move to star system'
		if action == 'Back':
			return 'Return to the universe'
	else:
		if action == 'Back':
			return 'Return to the system'
	return ''
	
onready var PlanetScene = preload("res://planet.tscn")
func generate_random_planets(ustar):
	print('generate_random_planets for: ', ustar)
	var planet_chance = 1.0
	var planet_chance_penalty_per_planet = 0.25
	var planets = []
	while Rand.check(planet_chance - len(planets) * planet_chance_penalty_per_planet):
		print('generate_random_planets add planet')
		var planet = PlanetScene.instance()
		planet.prepare_gas_giant(ustar)
		var angle = Rand.float_in_range(0, PI * 2)
		var distance = Rand.float_in_range(200, 400)
		var position = Vector2(distance, distance)
		position = position.rotated(angle)
		print(
			'generate_random_planets angle:', angle, ", distance: ", distance, 
			", position: ", position
		)
		planet.position = position
		planet.position.y *= 0.7
		planets.append(planet)
	print('generate_random_planets generated: ', len(planets))
	return planets
	
var ustar_to_planets = {}
func get_planets_by_ustar(ustar):
	print('get_planets_by_ustar: ', ustar)
	if not ustar_to_planets.has(ustar):
		print('get_planets_by_ustar not found: ', ustar)
		ustar_to_planets[ustar] = generate_random_planets(ustar)
	return ustar_to_planets[ustar]
	

func get_jump_range():
	return 100

func get_scan_range():
	return 250
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
