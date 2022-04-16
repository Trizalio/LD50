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
	
func move_all_starts_from_center(flight_duration):
	for star in ustars:
		var target_position = get_ustar_position_after_years(star, flight_duration)
		star.position = target_position
#		game.universe_map.animate(star, 'position', target_position, duration)
#		ustar.position *= (1 + force)

func get_time_to_build_ship():
	return 100

func advance_in_time(years: int):
	panel.cur_year += years
	move_all_starts_from_center(years)

func get_flight_duration(from, to):
	return int(from.position.distance_to(to.position))

func request_flight_confirmation(from, to):
	var flight_duration = get_flight_duration(from, to)
	if flight_duration > get_jump_range():
		game.display_modal(to.title + " is too far to send ship from " + from.title)
	else:
		game.display_modal(
			"Send ship from " + from.title + " to " + to.title + "?" + 
			"\nIt will take " + str(flight_duration) + " years, " + 
			"\nduring which the stars will scatter from each other", 
			"confirmation_got", [from, to]
		)

const float_double_range_per_years = 2000
func get_ustar_position_after_years(ustar, years: float) -> Vector2:
	return ustar.position * (float_double_range_per_years + years) / float_double_range_per_years

func check_for_game_over():
	print('check_for_game_over')
#	var ustars = ustar_to_planets.keys()
	var inhibited_stars_amount = 0
	var jump_range = get_jump_range()
	var checked: int = 0
	for i in range(0, len(ustars)):
		var current = ustars[i]
#		print(i, current.is_inhibitable)
		if current.is_inhibitable:
			inhibited_stars_amount += 1
		else:
			for j in range(i, len(ustars)):
				checked += 1
#				print(j)
				var other = ustars[j]
				if ((other.is_inhibitable or other.ships > 0) 
					and get_flight_duration(current, other) < jump_range):
					print('found after ', checked, ' checks')
					return
	print('not found what to do after', checked, ' checks')
	print("GAME OVER")
	
#	'cosmological horizon'
#	game.display_status("All not inhabited stars are too far", 1)
	Animator.call_delayed(game, 'display_status', 0, "All not inhabited stars are too far", 2)
	Animator.call_delayed(game, 'display_status', 2, "Your race is trapped on " + str(inhibited_stars_amount) + " stars", 3)
	Animator.call_delayed(game, 'display_status', 4, "And soon all of the unreachable stars will fade away into darkness ", 4)
	Animator.call_delayed(game, 'display_status', 4, "And all others will soon fade into darkness", 4)
	var text_end = 6
	var stars_dissappear_in = 4
	Animator.call_delayed(game, 'display_status', text_end + stars_dissappear_in, "Game over", 5)
	
	for i in range(0, len(ustars)):
		var current = ustars[i]
#		print(i, current.is_inhibitable)
		if not current.is_inhibitable:
			Animator.call_delayed(game.universe_map, 'animate', text_end, current, 'modulate', Color.transparent, stars_dissappear_in)
			
#	Animator.call_delayed(game.universe_map, 'animate', text_end, game.universe_map, 'modulate', Color.transparent, stars_dissappear_in)
	Animator.call_delayed(game.universe_map, 'animate', text_end, game.get_node("background/background_stars"), 'modulate', Color.transparent, stars_dissappear_in)
#	Animator.call_delayed(game.universe_map, "set", text_end + stars_dissappear_in, 'visible', false)
#	Animator.call_delayed(game, 'display_status', 1, "And sooner or later inhabited stars will become too far from each other", 2)
#	Animator.call_delayed(game, 'display_status', 1, "All ", 2)
#	SceneChanger.goto_scene("")
	
func confirmation_got(from, to):
	var flight_duration = get_flight_duration(from, to)
	var duration = pow(flight_duration, 0.5) / 5
	print("confirmation_got:", from, to)
	
	var ship = PlanetScene.instance()
	ship.prepare_uship()
	from.ships -= 1
	ship.position = from.position
	for star in game.ustars:
		var target_position = get_ustar_position_after_years(star, flight_duration)
		game.universe_map.animate(star, 'position', target_position, duration)
		
	game.ustars.append(ship)
	game.universe_map.animate(ship, 'position', get_ustar_position_after_years(to, flight_duration), duration)
	game.universe_map.animate(panel, 'cur_year', panel.cur_year + flight_duration, duration)
	
	Animator.call_delayed(to, "set_ships_amount", duration, to.ships + 1)
	game.universe_map.animate(game.universe_map, 'marks_rendered', 0, duration + 10.1)
	Animator.call_delayed(game, "track", duration, null)
	Animator.call_delayed(ship, "set", duration, 'visible', false)
	Animator.call_delayed(self, "check_for_game_over", duration)
	Animator.call_delayed(game, "rerender_galaxy", duration)
	game.track(ship)
	
#	to.ships += 1
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

const scan_power_decay_per = 1
const scan_speed = 300
func scan(source, scan_power: float, years: int):
	print('scan: ', len(ustars))
	var total_duration: float = 0
	if years:
		total_duration = 22 * 64 / (scan_speed * sqrt(2))
		print('total_duration: ', total_duration)
		
		game.universe_map.marks.wave_source = source.position
		game.universe_map.marks.wave_range = 0
		Animator.animate(game.universe_map.marks, 'wave_range', 1, total_duration, 
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		game.universe_map.animate(panel, 'cur_year', panel.cur_year + years, total_duration)
		
	for star in ustars:
		var distance = float(source.position.distance_to(star.position))
		var power = scan_power / (1 + distance / scan_power_decay_per)
		var target_value = star.scanned_power + power
		var delay = distance / scan_speed
		if years:
			var target_position = get_ustar_position_after_years(star, years)
			game.universe_map.animate(star, 'position', target_position, total_duration)
			Animator.call_delayed(game.universe_map, 'animate', delay, star, 
									'scanned_power', target_value)
		else:
			star.scanned_power = target_value
#		Animator.call_delayed(to, "set_ships_amount", duration, to.ships + 1)
#		game.universe_map.animate(star, 'scanned_power', target_value)
#		star.scanned_power += power
#		star.scanned_power = 1
	

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
		if action == 'Scan':
			scan(object, 50, 10)
			game.recall_universe_camera()
#			game.recall_universe_camera()
	else:
		if action == 'Back':
			game.recall_system_camera()
			
	if object.is_planet:
		if action == "Build ship":
			object.owner_ustar.ships += 1
			advance_in_time(get_time_to_build_ship())
			game.rerender_galaxy()
			game.ascend_to_universe()
			check_for_game_over()
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
				check_for_game_over()
		
#			game.recall_system_camera()
#		else:
#			game.ascend_to_universe()

func get_actions_for_object(object):
	var actions = []
	if object.is_ustar:
	
		actions += ["Scan"]
		if object.ships:
			actions += ["Send ship"]
		if object.ships or is_ustar_scannable(object):
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
	
	var angle = Rand.float_in_range(0, PI * 2)
	var distance = Rand.float_in_range(0, 600)
	var position = Vector2(distance, distance)
	position = position.rotated(angle)
	return position
	
#	var x = Rand.float_in_range(-650, 650) * 2
#	var y = Rand.float_in_range(-400, 400) * 2
#	return Vector2(x, y)
	
var ustars = []
const min_range_between_stars = 70
const stars_amount = 100
var vector
func generate_random_ustars():
	print('generate_random_stars')
	var stars = []
	var min_range_from_center = 10000
	var nearest_ustar = null
	while len(stars) < stars_amount:
#		print('generate_random_planets add planet')
		var new_star = PlanetScene.instance()
		new_star.prepare_ustar()
		var conflict = true
		while conflict:
			new_star.position = generate_random_squere_position()
			
			conflict = false
			for star in stars:
				if new_star.position.distance_to(star.position) < min_range_between_stars:
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
	scan(nearest_ustar, 25, 0)
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
	return 200

func get_scan_range():
	return 400
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
