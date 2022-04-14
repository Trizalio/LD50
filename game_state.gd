extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var game = null
var panel = null

func register_game(game):
	self.game = game
func register_panel(panel):
	self.panel = panel

func is_ustar_scannable(ustar):
	for other in ustars:
		if other.is_inhibitable and \
			ustar.position.distance_to(other.position) < other.get_scan_range():
				return true
	return false

func get_nearest_star_with_ships(pos: Vector2):
	var min_distance = 9999999
	var nearest_star = null
	for other in ustars:
		if other.ships > 0:
			var distance = pos.distance_to(other.position)
			if distance < other.get_jump_range() and distance < min_distance:
				min_distance = distance
				nearest_star = other
	return nearest_star
	
func is_ustar_reachable(ustar):
	var nearest_star = get_nearest_star_with_ships(ustar.position)
	if nearest_star:
		var distance = ustar.position.distance_to(nearest_star.position)
		return distance
	
func move_all_starts_from_center(force):
	for ustar in ustars:
		ustar.position *= (1 + force)

func get_time_to_build_ship():
	return 100

func advance_in_time(years: int):
	panel.cur_year += years
	move_all_starts_from_center(years / 1000)

func get_flight_duration(from, to):
	return int(from.position.distance_to(to.position))

func request_flight_confirmation(from, to):
	var flight_duration = get_flight_duration(from, to)
	game.display_modal(
		"Send ship from " + from.title + " to " + to.title + "?" + 
		"\nIt will take " + str(flight_duration) + " years, " + 
		"\nduring which the stars will scatter from each other", 
		"confirmation_got", [from, to]
	)
	
func confirmation_got(from, to):
	print("confirmation_got:", from, to)
	
	from.ships -= 1
	to.ships += 1
	game.rerender_galaxy()
	pass

var sending_ship_from_ustar = null
func ustar_selected(ustar):
	if sending_ship_from_ustar == null:
		return
		
	game.end_select_destination()
	game.display_status("")
	if ustar != null and ustar != sending_ship_from_ustar:
		request_flight_confirmation(sending_ship_from_ustar, ustar)
	sending_ship_from_ustar = null
	

func button_pressed(object, action: String):
	if object == null:
		print('wild button pressed')
		return
	if object.is_ustar:
		if action == 'Send ship':
			sending_ship_from_ustar = object
			game.display_status("Select star to send ship")
			game.start_select_destination(object)
			game.recall_universe_camera()
		if action == 'View':
			game.descend_into_star(object)
		if action == 'Back':
			game.recall_universe_camera()
	else:
		if action == 'Back':
			game.recall_system_camera()
			
	if object.is_planet:
		if action == "Build ship":
			object.owner_ustar.ships += 1
			advance_in_time(get_time_to_build_ship())
			game.rerender_galaxy()
			game.ascend_to_universe()
		if action == 'Colonise':
			var nearest_star = get_nearest_star_with_ships(object.owner_ustar.position)
			var distance = 0
			if nearest_star:
				distance = object.position.distance_to(nearest_star.position)
			if distance:
				nearest_star.ships -= 1
				object.is_inhibitable = true
				object.owner_ustar.is_inhibitable = true
				panel.max_materials += 10
				panel.max_energy += 10
				panel.cur_population += 10
				advance_in_time(distance)
				game.rerender_galaxy()
				game.ascend_to_universe()
#			game.recall_system_camera()
#		else:
#			game.ascend_to_universe()

func get_actions_for_object(object):
	var actions = []
	if object.is_ustar:
		
		if object.ships:
			actions += ["Send ship"]
		if is_ustar_scannable(object):
			actions += ["View"]
		
	if object.is_planet:
		
		if object.is_inhibitable:
			actions += ["Build ship"]
		elif not object.owner_ustar.is_inhibitable and object.owner_ustar.ships > 0:
#			var distance = is_ustar_reachable(object.owner_ustar)
#			if distance:
			actions += ["Colonise"]
			
#	if object.is_star:
	actions += ["Back"]
	return actions
	
			

func get_hint_for_object(object) -> String:
	var result = ''
	if object.is_ustar:
		if is_ustar_reachable(object):
			result = 'Colonisable star'
		elif is_ustar_scannable(object):
			result = 'Viewable star'
		else:
			result = 'Star out of scan range'
			
		
	if object.is_star:
		result = 'Star'
		
	if object.is_planet:
		if object.is_inhibitable:
			result = 'Colonised planet'
		elif is_ustar_reachable(object.owner_ustar):
			result = 'Colonisable planet'
		else:
			result = 'Too far too colonise planet'
		
	return '[center]' + result + '[/center]'

func get_hint_for_object_action(object, action: String):
	var result = ''
	if object.is_ustar:
		if action == 'View':
			result = 'Move to star system'
		if action == 'Back':
			result = 'Return to the universe'
	else:
		if action == 'Back':
			result = 'Return to the system'
		
	if object.is_planet:
		print('@action:', action)
		if action == "Build ship":
			result = ('Build giant ark ship, able to travel between stars, ' + 
				'spend ' + str(get_time_to_build_ship()) + ' years')
		if action == 'Colonise':
			var distance = is_ustar_reachable(object.owner_ustar)
			result = 'Colonise system, spend ' + str(int(distance)) + ' years'
	return '[center]' + result + '[/center]'
	

func generate_random_position():
	var angle = Rand.float_in_range(0, PI * 2)
	var distance = Rand.float_in_range(200, 400)
	var position = Vector2(distance, distance)
	position = position.rotated(angle)
	position.y *= 0.7
	return position
	
onready var PlanetScene = preload("res://planet.tscn")
func generate_random_planets(ustar):
	print('generate_random_planets for: ', ustar)
	var planet_chance = 1.0
	var planet_chance_penalty_per_planet = 0.25
	var planets = []
	while Rand.check(planet_chance - len(planets) * planet_chance_penalty_per_planet):
		print('generate_random_planets add planet')
		var new_planet = PlanetScene.instance()
		new_planet.prepare_earth_like_planet(ustar)
		var conflict = true
		while conflict:
			new_planet.position = generate_random_position()
			
			conflict = false
			for planet in planets:
				if new_planet.position.distance_to(planet.position) < 100:
					conflict = true
					print('conflict')
					break
					
		planets.append(new_planet)
	print('generate_random_planets generated: ', len(planets))
	return planets
	
func generate_random_squere_position():
	var x = Rand.float_in_range(-675, 675)
	var y = Rand.float_in_range(-375, 425)
	return Vector2(x, y)
	
var ustars = []
var vector
func generate_random_ustars():
	print('generate_random_stars')
	var stars = []
	var min_range_from_center = 10000
	var nearest_ustar = null
	while len(stars) < 50:
#		print('generate_random_planets add planet')
		var new_star = PlanetScene.instance()
		new_star.prepare_ustar()
		var conflict = true
		while conflict:
			new_star.position = generate_random_squere_position()
			
			conflict = false
			for star in stars:
				if new_star.position.distance_to(star.position) < 75:
					conflict = true
#					print('conflict')
					break
			
					
			if not conflict and new_star.position.length() < min_range_from_center:
				print(
					new_star.position, ' len: ', new_star.position.length(),
					' is less then ', min_range_from_center, ' set nearest to', 
					new_star
				)
				min_range_from_center = new_star.position.length()
				nearest_ustar = new_star
					
		stars.append(new_star)
	nearest_ustar.is_inhibitable = true
	nearest_ustar.ships = 1
	var planets = get_planets_by_ustar(nearest_ustar)
	var home_planet = Rand.choice(planets)
	home_planet.is_inhibitable = true
	print('generate_random_planets generated: ', len(stars))
	ustars = stars
	return stars

#func get_ustars():
#	generate_random_stars()

var ustar_to_planets = {}
func get_planets_by_ustar(ustar):
	print('get_planets_by_ustar: ', ustar)
	if not ustar_to_planets.has(ustar):
		print('get_planets_by_ustar not found: ', ustar)
		ustar_to_planets[ustar] = generate_random_planets(ustar)
	return ustar_to_planets[ustar]
	

func get_jump_range():
	return 150

func get_scan_range():
	return 300
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
