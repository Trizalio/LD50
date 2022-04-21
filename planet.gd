extends Node2D
class_name Planet

signal pressed
signal mouse_entered
signal mouse_exited


enum Building {shipyard, launchpad, observatory, storage}

var building = null setget set_building

func set_building(new_building):
	building = new_building
	update_selection_color()

var has_observatory: bool = false setget , get_has_observatory
var has_shipyard: bool = false setget , get_has_shipyard
var has_launchpad: bool = false setget , get_has_launchpad
var has_storage: bool = false setget , get_has_storage

func get_has_building(building_) -> bool:
	if is_ustar:
		for planet in planets:
			if planet.get_has_building(building_):
				return true
		return false
		
	var result = building == building_
#	print(building, ":get_has_building(", building_, "):", result)
	return result
	
func get_has_observatory() -> bool:
	return get_has_building(Building.observatory)
func get_has_shipyard() -> bool:
	return get_has_building(Building.shipyard)	
func get_has_launchpad() -> bool:
	return get_has_building(Building.launchpad)
func get_has_storage() -> bool:
	return get_has_building(Building.storage)
#	if is_ustar:
#		for planet in planets:
#			if planet.has_observatory:
#				return true
#		return false
#	return building == Building.observatory
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var size: float = 0.3 setget set_size
export var selection: float = 0 setget set_selection
export var seed_: Vector2 = Vector2(0, 0) setget set_seed
const anim_duration: float = 0.3
const anim_trans = Tween.TRANS_SINE
const anim_ease = Tween.EASE_IN_OUT
var is_ustar: bool = false
var is_star: bool = false
var is_planet: bool = false
var is_dwarf: bool = false
var is_giant: bool = false
var is_earth: bool = false
var is_ship: bool = false
var sprite: Sprite = null
var title: String
#var is_inhibitable: bool = false setget set_is_inhibitable
const gray_color: Color = Color(0.6, 0.6, 0.6, 1)
export var ships: int = 0 setget set_ships_amount
var scanned_power: float = 0 setget set_scanned_power
var planets: Array = [] setget , get_planets
var depletion: float = 0 setget set_depletion
const BUILDING_SELECTION_COLOR: Color = Color("#96007096")
const GOOD_SELECTION_COLOR: Color = Color("#9600c814")
const NEUTRAL_SELECTION_COLOR: Color = Color("#96966e00")
const BAD_SELECTION_COLOR: Color = Color("#96c80a00")
var population: float = 0 setget set_population, get_population
var selection_color: Color = NEUTRAL_SELECTION_COLOR setget set_selection_color
func mix_colors(first: Color, second: Color, power: float) -> Color:
	return first * (1 - power) + second * power
func update_selection_color():
	var color = mix_colors(
		mix_colors(
			mix_colors(NEUTRAL_SELECTION_COLOR, BUILDING_SELECTION_COLOR, int(building != null)), 
		GOOD_SELECTION_COLOR, get_population()),
		BAD_SELECTION_COLOR, depletion
	)
	set_selection_color(color)

func set_depletion(new_depletion: float):
	depletion = new_depletion
	sprite.material.set_shader_param("grayscale_power", depletion)
	update_selection_color()
#	set_selection_color(
#		NEUTRAL_SELECTION_COLOR * (1 - depletion) + BAD_SELECTION_COLOR * depletion
#	)
	
func set_selection_color(new_selection_color: Color):
	selection_color = new_selection_color
	sprite.material.set_shader_param("selection_color", selection_color)
	

func get_planets():
	if not planets and is_ustar:
		planets = generate_random_planets(self)
	return planets
		

func can_be_inspected():
	return scanned_power >= 0.6

func set_scanned_power(new_scanned_power: float):
	scanned_power = new_scanned_power
	if population > 0:
		scanned_power = 1
#	print(scanned_power)
	$ustar_labels/center/name.visible = scanned_power >= 0.6
	$button.visible = scanned_power >= 0.3
	self.modulate.a = clamp(scanned_power * 3, 0, 1)
	var scale = clamp(scanned_power * 5, 0, 1)
	self.scale = Vector2(scale, scale)
#	self.scale = clamp(0.3 + scanned_power * 3, )
#	$button.visible = scanned_power >= 0.5

func set_ships_amount(new_ships: int):
	ships = new_ships
	$ship.visible = ships > 0

#func set_is_inhibitable(new_is_inhibitable):
#	is_inhibitable = new_is_inhibitable
#	var ustar_name = $ustar_labels/center/name
#	var color = gray_color
#	if is_inhibitable:
#		color = Color.white
#	ustar_name.add_color_override("font_color", color)
#
#	set_scanned_power(scanned_power)

func get_population():
	if is_ustar:
		var result = 0
		for planet in planets:
			result += planet.population
		return result
	return population
		

func set_population(new_population: float):
#	owner_ustar.
	population = new_population
	var ustar_name = $ustar_labels/center/name
	var color = gray_color
	if population > 0:
		color = Color.white
	ustar_name.add_color_override("font_color", color)
	set_scanned_power(scanned_power)
	update_selection_color()

func set_size(new_size: float):
	size = new_size
	sprite.material.set_shader_param("size", size)
	var button = $button
	button.rect_size = sprite.texture.get_size() * sprite.scale * size * 2
	button.rect_position = -button.rect_size / 2
	var ustar_labels = $ustar_labels
	var ustar_name = $ustar_labels/center/name
	var scale = ustar_labels.rect_scale
	ustar_labels.rect_size = button.rect_size + Vector2(0, ustar_name.rect_size.y) * scale
	print(ustar_name.rect_size.x)
#	Artanis
	ustar_labels.rect_size.x = max(ustar_labels.rect_size.x, 1 *ustar_name.rect_size.x * scale.x)
#	ustar_labels.rect_size.x = max(ustar_labels.rect_size.x, 1 *ustar_name.rect_size.x * scale.x)
	ustar_labels.rect_size /= scale
	ustar_labels.rect_position = -ustar_labels.rect_size * scale / 2

func set_selection(new_selection: float):
	selection = new_selection
	sprite.material.set_shader_param("selection_gap", selection)

func set_seed(new_seed: Vector2):
	sprite.material.set_shader_param("seed", new_seed)
	seed_  = new_seed

const FIRST_NAMES = [
	'Acamar', 'Achernar', 'Achird', 'Acrux', 'Adara', 'Adhafera', 'Adhil', 'Agena', 
	'Aladfar', 'Albaldah', 'Albali', 'Albireo', 'Alchiba', 'Alcor', 'Aldhibah', 
	'Alfirk', 'Algenib', 'Algol', 'Algorab', 'Alhena', 'Alioth', 'Alkaid', 'Alkes', 
	'Almaak', 'Alnair', 'Alnath', 'Alnilam', 'Alnitak', 'Alniyat', 'Alniyat', 'Alphard', 
	'Alrai', 'Alrisha', 'Alsafi', 'Alshain', 'Alshat', 'Altair', 'Altarf', 'Aludra', 
	'Alya', 'Alzirr', 'Anser', 'Antares', 'Arcturus', 'Arkab', 'Arneb', 'Arrakis', 
	'Ascella', 'Asellus', 'Asterope', 'Atik', 'Atlas', 'Auva', 'Avior', 'Azha', 'Baham', 
	'Becrux', 'Beid', 'Botein', 'Brachium', 'Canopus', 'Capella', 'Castor', 'Cebalrai', 
	'Celaeno', 'Chara', 'Chort', 'Cursa', 'Dabih', 'Deneb', 'Diadem', 'Diphda', 
	'Dschubba', 'Dsiban', 'Electra', 'Elnath', 'Enif', 'Etamin', 'Fornacis', 'Furud', 
	'Gacrux', 'Gianfar', 'Gomeisa', 'Gorgonea', 'Grafias', 'Grumium', 'Hadar', 'Haedi', 
	'Hamal', 'Hassaleh', 'Heze', 'Homam', 'Izar', 'Jabbah', 'Kajam', 'Kaus', 'Keid', 
	'Kitalpha', 'Kraz', 'Kuma', 'Lesath', 'Maasym', 'Maia', 'Marfik', 'Markab', 'Matar', 
	'Mebsuta', 'Megrez', 'Meissa', 'Mekbuda', 'Menkar', 'Menkent', 'Menkib', 'Merak', 
	'Merga', 'Merope', 'Metallah', 'Minkar', 'Mintaka', 'Mira', 'Mirach', 'Miram', 
	'Mirphak', 'Mizar', 'Mufrid', 'Muliphen', 'Murzim', 'Muscida', 'Naos', 'Nash', 
	'Nashira', 'Nekkar', 'Nihal', 'Nusakan', 'Phad', 'Phaet', 'Pherkad', 'Pleione', 
	'Polaris', 'Pollux', 'Porrima', 'Procyon', 'Propus', 'Rana', 'Rastaban', 'Regulus', 
	'Rigel', 'Rotanev', 'Ruchba', 'Ruchbah', 'Sabik', 'Sadr', 'Saiph', 'Salm', 'Sargas', 
	'Sarin', 'Sceptrum', 'Scheat', 'Segin', 'Sham', 'Sharatan', 'Shaula', 'Shedir', 
	'Sheliak', 'Sirius', 'Situla', 'Skat', 'Spica', 'Sualocin', 'Subra', 'Sulafat', 
	'Syrma', 'Talitha', 'Tarazed', 'Taygeta', 'Tegmen', 'Thabit', 'Theemim', 'Thuban', 
	'Turais', 'Tyl', 'Vega', 'Wasat', 'Wezen', 'Yildun', 'Zaurak', 'Zibal'
]
const SECOND_NAMES = [
	"Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", 
	"Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", 
	"Chi", "Psi", "Omega"
]
func generate_star_name() -> String:
	return Rand.choice(FIRST_NAMES)
	
func generate_planet_name(ustar) -> String:
	return ustar.prepare_name_for_child_planet()
#	return ustar.title + " " + Rand.choice(SECOND_NAMES)

var child_planets_amount: int = 0
func prepare_name_for_child_planet() -> String:
	child_planets_amount += 1
	return self.title + " " + SECOND_NAMES[child_planets_amount - 1]

var start_position = null
# Called when the node enters the scene tree for the first time.
func _ready():
	set_selection(0)
#	set_scanned_power(scanned_power)
	start_position = position
#	$sprite.material = $sprite.material.duplicate()
	pass # Replace with function body.
	
func get_ship_build_cost() -> float:
	var result = GameState.SHIP_BUILD_COST_MATERIALS
	if get_has_shipyard():
		result = GameState.SHIP_BUILD_COST_MATERIALS_WITH_SHIPYARD
	return float(result)
	
func get_ship_build_duration() -> float:
	var result = GameState.SHIP_BUILD_DURATION
	if get_has_shipyard():
		result = GameState.SHIP_BUILD_DURATION_WITH_SHIPYARD
	return float(result)

func get_jump_range() -> float:
	var result: float = 0.0
	if ships:
		result = GameState.get_jump_range()
	
	if get_has_launchpad():
		result *= 3
		
	return result
	
func get_scan_range() -> float:
	var result: float = 0
	if ships:
		result = max(result, GameState.get_ship_observe_range())
	if population > 0:
		result = max(result, GameState.get_star_observe_range())
	if get_has_observatory():
		result = max(result, GameState.get_star_scan_range())
	return result
#	if population > 0:
#		return GameState.get_observe_range()
#	elif ships:
#		return GameState.get_jump_range()
#	else:
#		return 0.0
func get_resources_base_amount() -> float:
	return pow(size, 2) * (1 - depletion) * 2000
func get_materials_amount() -> float:
	var materials_coef = 1
	if is_dwarf:
		materials_coef = 3
	if is_giant:
		materials_coef = 0.1
	var result = get_resources_base_amount() * materials_coef
	print('get_materials_amount:', result)
	return result
func get_energy_amount() -> float:
	var energy_coef = 1
	if is_dwarf:
		energy_coef = 0.5
	if is_giant:
		energy_coef = 1
	return get_resources_base_amount() * energy_coef
		
onready var name_node = $ustar_labels/center/name
func on_zoomed():
	Animator.animate(name_node, "modulate", Color.transparent, anim_duration, anim_trans, anim_ease)
	
func on_unzoomed():
	Animator.animate(name_node, "modulate", Color.white, anim_duration, anim_trans, anim_ease)

func _prepare_any():
	$ustar_labels/center/name.text = title
	sprite.visible = true
	sprite.material = sprite.material.duplicate()
	if not is_ustar:
		scanned_power = 1
	if is_planet:
		set_seed(Vector2(Rand.float_in_range(0, 100), Rand.float_in_range(0, 100)))
	

var owner_ustar = null
func prepare_star(ustar):
	is_star = true
	owner_ustar = ustar
	sprite = $star_sprite
	title = ustar.title
	_prepare_any()
	set_size(Rand.float_in_range(0.3, 0.4))
	return self
	
func _prepare_planet(ustar):
	is_planet = true
	owner_ustar = ustar
	sprite = $planet_sprite
	title = generate_planet_name(ustar)
	_prepare_any()
	return self
	
func hsv(h: float, s: float, v: float, a: float) -> Color:
	var hsv_val = Color.from_hsv(h / 360, s / 100, v / 100, a / 255)
	print('hsv_val:', hsv_val)
	return hsv_val



func prepare_dwarf_planet(ustar):
	_prepare_planet(ustar)
	is_dwarf = true
	set_size(Rand.float_in_range(0.1, 0.2))
	sprite.material.set_shader_param("main_color", 
		hsv(0 + Rand.frange(0, 255), 50 + Rand.frange(-25, 25), 50 + Rand.frange(-25, 25), 255))
	sprite.material.set_shader_param("second_color", 
		hsv(0 + Rand.frange(0, 255), 50 + Rand.frange(-25, 25), 30 + Rand.frange(-25, 25), 255))
	sprite.material.set_shader_param("atmosphere_color", hsv(0, 0, 0, 0))
	sprite.material.set_shader_param("rotation_speed", Rand.float_in_range(0.05, 0.2))
	sprite.material.set_shader_param("striping", Rand.float_in_range(0.8, 1.2))
	sprite.material.set_shader_param("main_and_second_colors_mixing", Rand.float_in_range(0.35, 0.5))
	sprite.material.set_shader_param("ice_amount", 0)
	sprite.material.set_shader_param("relief_power", Rand.float_in_range(0.4, 0.5))
	return self
	
func prepare_earth_like_planet(ustar):
	_prepare_planet(ustar)
	is_earth = true
	set_size(Rand.float_in_range(0.2, 0.3))
	sprite.material.set_shader_param("main_color", 
		hsv(193 + Rand.frange(-25, 25), 100 + Rand.frange(-15, 0), 64 + Rand.frange(-15, 15), 255))
	sprite.material.set_shader_param("second_color", 
		hsv(115 + Rand.frange(-25, 25), 100 + Rand.frange(-15, 0), 33 + Rand.frange(-15, 15), 255))	
	sprite.material.set_shader_param("atmosphere_color", hsv(193, 100, 64, 100))
	sprite.material.set_shader_param("atmosphere_amount", Rand.float_in_range(0.15, 0.25))
	sprite.material.set_shader_param("rotation_speed", Rand.float_in_range(0.05, 0.2))
	sprite.material.set_shader_param("striping", Rand.float_in_range(0.8, 1.2))
	sprite.material.set_shader_param("main_and_second_colors_mixing", Rand.float_in_range(0.05, 0.15))
	sprite.material.set_shader_param("ice_amount", Rand.float_in_range(0.2, 0.5))
	sprite.material.set_shader_param("relief_power", Rand.float_in_range(0.4, 0.5))
	return self
	
func prepare_gas_giant(ustar):
	_prepare_planet(ustar)
	is_giant = true
	set_size(Rand.float_in_range(0.3, 0.4))
	sprite.material.set_shader_param("main_color", 
		hsv(0 + Rand.frange(0, 255), 40 + Rand.frange(-25, 15), 60 + Rand.frange(-25, 25), 255))
#		hsv(0, 0, 0, 255))
#		hsv(200, 100, 100, 255))
	sprite.material.set_shader_param("second_color", 
		hsv(0 + Rand.frange(0, 255), 40 + Rand.frange(-25, 15), 60 + Rand.frange(-25, 25), 255))
#		hsv(0, 0, 0, 255))
#		hsv(200, 110, 100, 255))
	sprite.material.set_shader_param("atmosphere_color", 
		hsv(0 + Rand.frange(0, 255), 40 + Rand.frange(-25, 15), 60 + Rand.frange(-25, 25), 50))
#		hsv(0, 0, 0, 255))
#		hsv(200, 110, 100, 255))
	sprite.material.set_shader_param("rotation_speed", Rand.float_in_range(0.05, 0.2))
#	sprite.material.set_shader_param("striping", Rand.float_in_range(1.0, 1.5))
	sprite.material.set_shader_param("striping", Rand.float_in_range(1.75, 2.25))
	sprite.material.set_shader_param("main_and_second_colors_mixing", Rand.float_in_range(0.5, 0.7))
	sprite.material.set_shader_param("ice_amount", 0)
	sprite.material.set_shader_param("relief_power", 0)
#	sprite.material.set_shader_param("atmosphere_color", "2e2d436d")
	return self
	
func prepare_ustar():
	is_ustar = true
	title = generate_star_name()
	sprite = $ustar_sprite
	_prepare_any()
	set_size(Rand.float_in_range(0.3, 0.4))
	sprite.material.set_shader_param("rotation_speed", Rand.float_in_range(0.05, 0.2))
	return self
	
func prepare_uship():
	is_ship = true
	title = ''
	sprite = $ship
	_prepare_any()
#	set_size(Rand.float_in_range(0.3, 0.4))
	sprite.material.set_shader_param("circle_center_range", 0.0)
	return self
	

func generate_random_position():
	var angle = Rand.float_in_range(0, PI * 2)
	var distance = Rand.float_in_range(200, 350)
	var position = Vector2(distance, distance)
	position = position.rotated(angle)
	position.y *= 0.6
	return position
	
func add_earth_planet():
	var new_planet = PlanetScene.instance()
	new_planet.prepare_earth_like_planet(self)
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
	return new_planet
	
	
var PlanetScene = load("res://planet.tscn")
func generate_random_planets(ustar):
	print('generate_random_planets for: ', ustar)
	var planet_chance = 1.0
	var planet_chance_penalty_per_planet = 0.2
	var planets = []
#	while len(planets) < 20:
	while Rand.check(planet_chance - len(planets) * planet_chance_penalty_per_planet):
		print('generate_random_planets add planet')
		var new_planet = PlanetScene.instance()
#		new_planet.prepare_earth_like_planet(ustar)
#		new_planet.prepare_gas_giant(ustar)
		if Rand.check(1.0/3.0):
			new_planet.prepare_earth_like_planet(ustar)
		elif Rand.check(1.0/2.0):
			new_planet.prepare_gas_giant(ustar)
		else:
			new_planet.prepare_dwarf_planet(ustar)
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
	

func _process(delta):
#	$sprite.material.set_shader_param("shrink", target_shrink)
	pass

func animate_selection(target_value: float):
	Animator.animate(self, "selection", target_value, anim_duration, anim_trans, anim_ease)

func _on_mouse_entered():
	emit_signal("mouse_entered")
	animate_selection(0.05)
	print('mouse_entered')
#	var tween = get_node("tween")
#	tween.interpolate_property(self, "selection", selection, 0.05, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#	tween.start()

func _on_mouse_exited():
	emit_signal("mouse_exited")
	animate_selection(0)
#	var tween = get_node("tween")
#	tween.interpolate_property(self, "selection", selection, 0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#	tween.start()
	pass # Replace with function body.


func _on_Button_pressed():
	emit_signal("pressed")
#	print('pressed')
#	pass # Replace with function body.
