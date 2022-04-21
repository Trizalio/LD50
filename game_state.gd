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

#func is_ustar_scannable(ustar):
#	for other in ustars:
#		if other.population > 0 and \
#			ustar.position.distance_to(other.position) < other.get_scan_range():
#				return true
#	return false

#func get_nearest_star_with_ships(pos: Vector2):
#	var min_distance = 9999999
#	var nearest_star = null
#	for other in ustars:
#		if other.ships > 0:
#			var distance = pos.distance_to(other.position)
#			if distance < other.get_jump_range() and distance < min_distance:
#				min_distance = distance
#				nearest_star = other
#	return nearest_star
	
#func is_ustar_reachable(ustar):
#	var nearest_star = get_nearest_star_with_ships(ustar.position)
#	if nearest_star:
#		var distance = ustar.position.distance_to(nearest_star.position)
#		return distance
	
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
	if flight_duration > from.get_jump_range():
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
#		print(i, current.population)
		if current.population > 0:
			inhibited_stars_amount += 1
		else:
			for j in range(i, len(ustars)):
				checked += 1
#				print(j)
				var other = ustars[j]
				if ((other.population or other.ships > 0) 
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
#		print(i, current.population)
		if current.population == 0:
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

const scan_power_decay_per = 10
#const scan_speed = 300
func scan(source, scan_power: float, years: int, color: Color = Color.white, 
			scan_speed: int = 200, show_duration: float = 0.5):
	print('scan: ', len(ustars))
	var total_duration: float = 0
	if years:
		total_duration = 22 * 64 / (scan_speed * sqrt(2))
		print('total_duration: ', total_duration)
		
		game.universe_map.marks.wave_source = source.position
		game.universe_map.marks.wave_range = 0
		game.universe_map.marks.wave_color = color
		Animator.animate(game.universe_map.marks, 'wave_range', 1, total_duration, 
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		game.universe_map.animate(panel, 'cur_year', panel.cur_year + years, total_duration)
		
	for star in ustars:
		var distance = float(source.position.distance_to(star.position))
		var power = scan_power / (1 + pow(distance / scan_power_decay_per, 2))
		var target_value = star.scanned_power + power
		var delay = distance / scan_speed
		if years:
			var target_position = get_ustar_position_after_years(star, years)
			game.universe_map.animate(star, 'position', target_position, total_duration)
			Animator.call_delayed(game.universe_map, 'animate', delay, star, 
									'scanned_power', target_value, show_duration)
		else:
			star.scanned_power = target_value
#		Animator.call_delayed(to, "set_ships_amount", duration, to.ships + 1)
#		game.universe_map.animate(star, 'scanned_power', target_value)
#		star.scanned_power += power
#		star.scanned_power = 1

func change_year(value: int, duration: float = 0.7):
	game.universe_map.animate(panel, 'cur_year', panel.cur_year + value, duration)

func change_population(value: int, duration: float = 0.7):
	game.universe_map.animate(panel, 'cur_population', panel.cur_population + value, duration)

func change_materials(value: int, duration: float = 0.7):
	game.universe_map.animate(panel, 'cur_materials', panel.cur_materials + value, duration)

func change_energy(value: int, duration: float = 0.7):
	game.universe_map.animate(panel, 'cur_energy', panel.cur_energy + value, duration)
	
func change_max_materials(value: int, duration: float = 0.7):
	game.universe_map.animate(panel, 'max_materials', panel.max_materials + value, duration)

func change_max_energy(value: int, duration: float = 0.7):
	game.universe_map.animate(panel, 'max_energy', panel.max_energy + value, duration)
	

enum Building {shipyard, launchpad, observatory, storage}
const LAUNCHPAD_BUILD_COST_MATERIALS: int = 250
const SHIPYARD_BUILD_COST_MATERIALS: int = 160
const OBSERVATORY_BUILD_COST_MATERIALS: int = 120
const STORAGE_BUILD_COST_MATERIALS: int = 80
const SHIP_BUILD_COST_MATERIALS: int = 75
const SHIP_BUILD_COST_MATERIALS_WITH_SHIPYARD: int = 50
const SHIP_BUILD_DURATION: int = 50
const SHIP_BUILD_DURATION_WITH_SHIPYARD: int = 30
const SCAN_COST: int = 30
const OBSERVE_DURATION: int = 50
const SCAN_DURATION: int = 5
func button_pressed(object, action: String):
	if object == null:
		print('wild button pressed')
		return
	if object.is_ustar:
		if action == 'Send ship':
			current_jump_range = object.get_jump_range()
			sending_ship_from_ustar = object
			game.display_status("Select star to send ship")
			game.start_select_destination(object)
			game.recall_universe_camera()
		if action == 'Build ship':
			object.ships += 1
			change_materials(-object.get_ship_build_cost())
			var build_duration = object.get_ship_build_duration()
			var animation_duration = pow(build_duration, 0.5) / 3
			change_year(build_duration, animation_duration)
					
			for star in game.ustars:
				var target_position = get_ustar_position_after_years(star, build_duration)
				game.universe_map.animate(star, 'position', target_position, animation_duration)
				
			game.rerender_galaxy()
			game.recall_universe_camera()
		if action == 'View':
			game.descend_into_star(object)
#			if object.can_be_inspected():
#				game.descend_into_star(object)
#			else:
#				game.recall_universe_camera()
		if action == 'Observe':
			scan(object, 80, OBSERVE_DURATION, Color.transparent, 1000, 2)
			game.recall_universe_camera()
		if action == 'Scan':
			scan(object, 300, SCAN_DURATION)
			change_energy(-SCAN_COST)
			game.recall_universe_camera()
		if action == 'Back':
			game.recall_universe_camera()
	else:
		if action == 'Back':
			game.recall_system_camera()
			
	if object.is_planet:
		if action == "Extract":
			object.population = 0
			game.recall_system_camera()
			game.universe_map.animate(object, 'depletion', 1)
			change_materials(object.get_materials_amount())
			change_energy(object.get_energy_amount())
		elif action == "Build scanner":
			object.building = object.Building.observatory
			change_materials(-OBSERVATORY_BUILD_COST_MATERIALS)
			game.recall_system_camera()
			game.rerender_galaxy()
		elif action == "Build shipyard":
			object.building = object.Building.shipyard
			change_materials(-SHIPYARD_BUILD_COST_MATERIALS)
			game.recall_system_camera()
		elif action == "Build launch pad":
			object.building = object.Building.launchpad
			change_materials(-LAUNCHPAD_BUILD_COST_MATERIALS)
			game.recall_system_camera()
			game.rerender_galaxy()
		elif action == "Build storage":
			object.building = object.Building.storage
			change_materials(-STORAGE_BUILD_COST_MATERIALS)
			change_max_materials(500)
			change_max_energy(500)
			game.recall_system_camera()
		elif action == "Build colony":
			game.universe_map.animate(object, 'population', 1)
			object.owner_ustar.population = 1
			change_population(10)
			game.recall_system_camera()
			object.owner_ustar.ships -= 1
			game.rerender_galaxy()
			
			pass
	
		
#		if action == "Build ship":
#			object.owner_ustar.ships += 1
#			advance_in_time(get_time_to_build_ship())
#			game.rerender_galaxy()
#			game.ascend_to_universe()
#			check_for_game_over()
#		if action == 'Colonise':
#			var nearest_star = get_nearest_star_with_ships(object.owner_ustar.position)
#			var distance = 0
#			if nearest_star:
#				distance = object.position.distance_to(nearest_star.position)
#			if distance:
#				nearest_star.ships -= 1
#				object.population = 1
#				object.owner_ustar.population = 1
#				panel.max_materials += 10
#				panel.max_energy += 10
#				panel.cur_population += 10
#				advance_in_time(distance)
#				game.rerender_galaxy()
#				game.ascend_to_universe()
#				check_for_game_over()

func to_first_upper(string: String) -> String:
	var result = string.substr(0, 1).to_upper() + string.substr(1)
	return result

func add_action_with_condition(actions: Array, action: String, condition: bool):
	if not condition:
		action = "-" + action
	actions.append(action)
	

func get_actions_for_object(object):
	var actions = []
	if object.is_ustar:
	
		if object.population:
			actions += ["Observe"]
			
		if object.has_observatory:
			
			add_action_with_condition(actions, "Scan", panel.cur_energy >= SCAN_COST)
#			var scan = "Scan"
#			if panel.cur_energy < SCAN_COST:
#				scan = '-' + scan
#			actions += [scan]
			
		if object.ships:
			actions += ["Send ship"]
		elif object.population:
			add_action_with_condition(actions, "Build ship", panel.cur_materials >= object.get_ship_build_cost())
			
		add_action_with_condition(actions, "View", object.can_be_inspected() or object.ships)
		
	if object.is_planet:
		if not object.building:
			if object.owner_ustar.population > 0:
				if object.depletion == 0.0 and object.population == 0.0:
					actions += ["Extract"]
					
				add_action_with_condition(actions, "Build scanner", 
					panel.cur_materials >= OBSERVATORY_BUILD_COST_MATERIALS)
				add_action_with_condition(actions, "Build shipyard", 
					panel.cur_materials >= SHIPYARD_BUILD_COST_MATERIALS)
				if object.is_earth or object.is_dwarf:
					add_action_with_condition(actions, "Build launch pad", 
						panel.cur_materials >= LAUNCHPAD_BUILD_COST_MATERIALS)
					add_action_with_condition(actions, "Build storage", 
						panel.cur_materials >= STORAGE_BUILD_COST_MATERIALS)
			elif object.owner_ustar.ships > 0:
				if object.depletion == 0.0:
					actions += ["Extract"]
				if object.is_earth:
					actions += ["Build colony"]
			else:
				pass
			
	actions += ["Back"]
	return actions
	
			

func get_hint_for_object(object) -> String:
	var result = ''
	if object.is_ustar:
		result = 'star'
		if object.population > 0:
			result = 'colonised ' + result
		
		if object.ships:
			result += ' with a ship'
#		if is_ustar_reachable(object):
#			result = 'Colonisable star'
#		elif is_ustar_scannable(object):
#			result = 'Viewable star'
#		else:
#			result = 'Star out of scan range'
			
		
	if object.is_star:
		result = 'star'
		
	if object.is_planet:
		result = 'planet'
		if object.is_earth:
			result = "earth-like " + result
		elif object.is_giant:
			result = "gas giant " + result
		elif object.is_dwarf:
			result = "dwarf " + result
		else:
			result = "unknown " + result
		
		if object.depletion > 0:
			result = "depleted " + result
			
		if object.population:
			result = 'colonised ' + result
		
		if object.has_observatory:
			result += " with a space scanner"
		if object.has_shipyard:
			result += " with an orbital shipyard"
		if object.has_launchpad:
			result += " with an interstellar launch pad"
		if object.has_storage:
			result += " with storage facilities"
			
	result = to_first_upper(result)
	return '[center]' + result + '[/center]'

func get_hint_for_object_action(object, action: String):
	var result = ''
	if object.is_ustar:
		if action == 'Observe':
			result = "Inefficient, slow but free way to explore the area"
		if action == 'Scan':
			if panel.cur_energy >= SCAN_COST:
				result = (
					"Use space scanner to scan surroundings\n" + 
					"It requires " + str(SCAN_DURATION) + " years" +
					" and " + str(SCAN_COST) + " energy"
				)
			else:
				result = ("Missing required " + str(SCAN_COST) + " energy to scan")
		if action == 'View':
			if object.can_be_inspected():
				result = 'Move to star system'
			else:
				result = 'Observe or scan more to inspect planets'
		if action == 'Back':
			result = 'Return to the universe'
	else:
		if action == 'Back':
			result = 'Return to the system'
		
	if object.is_planet:
		if action == 'Extract':
			result = ('Extract all resources from a planet, ' +
					 'building or colonies will be destroyed, and cannot be rebuilt')
		if action == 'Build scanner':
			if panel.cur_materials >= OBSERVATORY_BUILD_COST_MATERIALS:
				result = 'Build a space scanner to explore surroundings faster'
			else:
				result = ("Missing required " + str(OBSERVATORY_BUILD_COST_MATERIALS) 
					+ " materials to build a space scanner")
		if action == 'Build shipyard':
			if panel.cur_materials >= SHIPYARD_BUILD_COST_MATERIALS:
				result = 'Build an orbital shipyard to build ships faster and cheaper'
			else:
				result = ("Missing required " + str(SHIPYARD_BUILD_COST_MATERIALS) 
					+ " materials to build an orbital shipyard")
		if action == 'Build launch pad':
			if panel.cur_materials >= LAUNCHPAD_BUILD_COST_MATERIALS:
				result = 'Build an interstellar launch pad to travel further from this star'
			else:
				result = ("Missing required " + str(LAUNCHPAD_BUILD_COST_MATERIALS) 
					+ " materials to build an interstellar launch pad")
		if action == 'Build storage':
			if panel.cur_materials >= STORAGE_BUILD_COST_MATERIALS:
				result = 'Build storage facilities to keep more materials and energy'
			else:
				result = ("Missing required " + str(STORAGE_BUILD_COST_MATERIALS) 
					+ " materials to build storage facilities")
		if action == 'Build colony':
			result = ("Use ship to found a colony, which allows building structures" +
						"in this system")
					
	result = to_first_upper(result)
	return '[center]' + result + '[/center]'
	
#
#func generate_random_position():
#	var angle = Rand.float_in_range(0, PI * 2)
#	var distance = Rand.float_in_range(200, 400)
#	var position = Vector2(distance, distance)
#	position = position.rotated(angle)
#	position.y *= 0.7
#	return position
#
onready var PlanetScene = preload("res://planet.tscn")
#func generate_random_planets(ustar):
#	print('generate_random_planets for: ', ustar)
#	var planet_chance = 1.0
#	var planet_chance_penalty_per_planet = 0.25
#	var planets = []
#	while Rand.check(planet_chance - len(planets) * planet_chance_penalty_per_planet):
#		print('generate_random_planets add planet')
#		var new_planet = PlanetScene.instance()
#		new_planet.prepare_earth_like_planet(ustar)
#		var conflict = true
#		while conflict:
#			new_planet.position = generate_random_position()
#
#			conflict = false
#			for planet in planets:
#				if new_planet.position.distance_to(planet.position) < 100:
#					conflict = true
#					print('conflict')
#					break
#
#		planets.append(new_planet)
#	print('generate_random_planets generated: ', len(planets))
#	return planets
	
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
	nearest_ustar.population = 1
#	nearest_ustar.ships = 1
	var planets = get_planets_by_ustar(nearest_ustar)
	var home_planet = nearest_ustar.add_earth_planet()
#	var home_planet = Rand.choice(planets)
	home_planet.population = 1
	print('generate_random_planets generated: ', len(stars))
	ustars = stars
	scan(nearest_ustar, 50, 0)
	return stars

#func get_ustars():
#	generate_random_stars()

#var ustar_to_planets = {}
func get_planets_by_ustar(ustar):
	return ustar.planets
#	print('get_planets_by_ustar: ', ustar)
#	if not ustar_to_planets.has(ustar):
#		print('get_planets_by_ustar not found: ', ustar)
#		ustar_to_planets[ustar] = generate_random_planets(ustar)
#	return ustar_to_planets[ustar]
	
var current_jump_range = null
func get_current_jump_range():
	return current_jump_range

func get_jump_range():
	return 150

const observe_power_to_range_factor: float = 3.0
func get_ship_observe_range():
	return 50 * observe_power_to_range_factor

func get_star_observe_range():
	return 80 * observe_power_to_range_factor

func get_star_scan_range():
	return 150 * observe_power_to_range_factor

#func get_scan_range():
#	return 400
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
