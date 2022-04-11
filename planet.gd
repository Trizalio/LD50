extends Node2D
class_name Planet

signal pressed
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
var sprite: Sprite = null
var title: String
var is_inhibitable: bool = false setget set_is_inhibitable
const gray_color: Color = Color(0.6, 0.6, 0.6, 1)
var ships: int = 0 setget set_ships_amount

func set_ships_amount(new_ships: int):
	ships = new_ships
	$ship.visible = ships > 0

func set_is_inhibitable(new_is_inhibitable):
	is_inhibitable = new_is_inhibitable
	var ustar_name = $ustar_labels/center/name
	var color = gray_color
	if is_inhibitable:
		color = Color.white
	ustar_name.add_color_override("font_color", color)

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
	"ACAMAR", "ACHERNAR", "Achird", "ACRUX", "Acubens", "ADARA", "Adhafera", "Adhil", 
	"AGENA", "Aladfar", "Alathfar", "Albaldah", "Albali", "ALBIREO", "Alchiba", "ALCOR", 
	"ALCYONE", "ALDEBARAN", "ALDERAMIN", "Aldhibah", "Alfecca Meridiana", "Alfirk", 
	"ALGENIB", "ALGIEBA", "ALGOL", "Algorab", "ALHENA", "ALIOTH", "ALKAID", "Alkalurops", 
	"Alkes", "Alkurhah", "ALMAAK", "ALNAIR", "ALNATH", "ALNILAM", "ALNITAK", "Alniyat", 
	"Alniyat", "ALPHARD", "ALPHEKKA", "ALPHERATZ", "Alrai", "Alrisha", "Alsafi", "Alsciaukat", 
	"ALSHAIN", "Alshat", "Alsuhail", "ALTAIR", "Altarf", "Alterf", "Aludra", "Alula Australis", 
	"Alula Borealis", "Alya", "Alzirr", "Ancha", "Angetenar", "ANKAA", "Anser", "ANTARES", 
	"ARCTURUS", "Arkab Posterior", "Arkab Prior", "ARNEB", "Arrakis", "Ascella", 
	"Asellus Australis", "Asellus Borealis", "Asellus Primus", "Asellus Secondus", 
	"Asellus Tertius", "Asterope", "Atik", "Atlas", "Auva", "Avior", "Azelfafage", 
	"Azha", "Azmidiske", "Baham", "Baten Kaitos", "Becrux", "Beid", "BELLATRIX", 
	"BETELGEUSE", "Botein", "Brachium", "CANOPUS", "CAPELLA", "Caph", "CASTOR", 
	"Cebalrai", "Celaeno", "Chara", "Chort", "COR CAROLI", "Cursa", "Dabih", "Deneb Algedi", 
	"Deneb Dulfim", "Deneb el Okab", "Deneb el Okab", "Deneb Kaitos Shemali", "DENEB", 
	"DENEBOLA", "Dheneb", "Diadem", "DIPHDA", "Dschubba", "Dsiban", "DUBHE", 
	"Ed Asich", "Electra", "ELNATH", "ENIF", "ETAMIN", "FOMALHAUT", "Fornacis", 
	"Fum al Samakah", "Furud", "Gacrux", "Gianfar", "Gienah Cygni", "Gienah Ghurab",
	 "Gomeisa", "Gorgonea Quarta", "Gorgonea Secunda", "Gorgonea Tertia", "Graffias", 
	"Grafias", "Grumium", "HADAR", "Haedi", "HAMAL", "Hassaleh", "Head of Hydrus", 
	"Heze", "Hoedus II", "Homam", "Hyadum I", "Hyadum II", "IZAR", "Jabbah", 
	"Kaffaljidhma", "Kajam", "KAUS AUSTRALIS", "Kaus Borealis", "Kaus Meridionalis", 
	"Keid", "Kitalpha", "KOCAB", "Kornephoros", "Kraz", "Kuma", "Lesath", "Maasym", 
	"Maia", "Marfak", "Marfak", "Marfic", "Marfik", "MARKAB", "Matar", "Mebsuta", 
	"MEGREZ", "Meissa", "Mekbuda", "Menkalinan", "MENKAR", "Menkar", "Menkent", 
	"Menkib", "MERAK", "Merga", "Merope", "Mesarthim", "Metallah", "Miaplacidus", 
	"Minkar", "MINTAKA", "MIRA", "MIRACH", "Miram", "MIRPHAK", "MIZAR", "Mufrid",
	 "Muliphen", "Murzim", "Muscida", "Muscida", "Muscida", "Nair al Saif", "Naos", 
	"Nash", "Nashira", "Nekkar", "NIHAL", "Nodus Secundus", "NUNKI", "Nusakan", 
	"Peacock", "PHAD", "Phaet", "Pherkad Minor", "Pherkad", "Pleione", "Polaris Australis", 
	"POLARIS", "POLLUX", "Porrima", "Praecipua", "Prima Giedi", "PROCYON", "Propus", "Propus", 
	"Propus", "Rana", "Ras Elased Australis", "Ras Elased Borealis", "RASALGETHI", "RASALHAGUE", 
	"Rastaban", "REGULUS", "Rigel Kentaurus", "RIGEL", "Rijl al Awwa", "Rotanev", "Ruchba", 
	"Ruchbah", "Rukbat", "Sabik", "Sadalachbia", "SADALMELIK", "Sadalsuud", "Sadr", "SAIPH", 
	"Salm", "Sargas", "Sarin", "Sceptrum", "SCHEAT", "Secunda Giedi", "Segin", "Seginus", 
	"Sham", "Sharatan", "SHAULA", "SHEDIR", "Sheliak", "SIRIUS", "Situla", "Skat", "SPICA", 
	"Sterope II", "Sualocin", "Subra", "Suhail al Muhlif", "Sulafat", "Syrma", 
	"Talitha", "Tania Australis", "Tania Borealis", "TARAZED", "Taygeta", "Tegmen", 
	"Tejat Posterior", "Terebellum", "Terebellum", "Terebellum", "Terebellum", "Thabit", 
	"Theemim", "THUBAN", "Torcularis Septentrionalis", "Turais", "Tyl", "UNUKALHAI", "VEGA", 
	"VINDEMIATRIX", "Wasat", "Wezen", "Wezn", "Yed Posterior", "Yed Prior", "Yildun", 
	"Zaniah", "Zaurak", "Zavijah", "Zibal", "Zosma"
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
	return self.title + " " + SECOND_NAMES[child_planets_amount]

var start_position = null
# Called when the node enters the scene tree for the first time.
func _ready():
	start_position = position
#	$sprite.material = $sprite.material.duplicate()
	pass # Replace with function body.
	
func get_jump_range() -> float:
	if ships:
		return GameState.get_jump_range()
	else:
		return 0.0
	
func get_scan_range() -> float:
	if is_inhibitable:
		return GameState.get_scan_range()
	else:
		return 0.0
		
onready var name_node = $ustar_labels/center/name
func on_zoomed():
	Animator.animate(name_node, "modulate", Color.transparent, anim_duration, anim_trans, anim_ease)
	
func on_unzoomed():
	Animator.animate(name_node, "modulate", Color.white, anim_duration, anim_trans, anim_ease)

func _prepare_any():
	$ustar_labels/center/name.text = title
	sprite.visible = true
	sprite.material = sprite.material.duplicate()
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
	
func prepare_dwarf_planet(ustar):
	_prepare_planet(ustar)
	return self
	
func prepare_earth_like_planet(ustar):
	_prepare_planet(ustar)
	set_size(Rand.float_in_range(0.2, 0.3))
	sprite.material.set_shader_param("rotation_speed", Rand.float_in_range(0.05, 0.2))
	sprite.material.set_shader_param("striping", Rand.float_in_range(1.0, 2.0))
	sprite.material.set_shader_param("ice_amount", Rand.float_in_range(0.2, 0.5))
	return self
	
func prepare_gas_giant(ustar):
	_prepare_planet(ustar)
	return self
	
func prepare_ustar():
	is_ustar = true
	title = generate_star_name()
	sprite = $ustar_sprite
	_prepare_any()
	set_size(Rand.float_in_range(0.3, 0.4))
	sprite.material.set_shader_param("rotation_speed", Rand.float_in_range(0.05, 0.2))
	return self
	

func _process(delta):
#	$sprite.material.set_shader_param("shrink", target_shrink)
	pass

func animate_selection(target_value: float):
	Animator.animate(self, "selection", target_value, anim_duration, anim_trans, anim_ease)

func _on_mouse_entered():
	animate_selection(0.05)
	print('mouse_entered')
#	var tween = get_node("tween")
#	tween.interpolate_property(self, "selection", selection, 0.05, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#	tween.start()


func _on_mouse_exited():
	animate_selection(0)
#	var tween = get_node("tween")
#	tween.interpolate_property(self, "selection", selection, 0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#	tween.start()
	pass # Replace with function body.


func _on_Button_pressed():
	emit_signal("pressed")
#	print('pressed')
#	pass # Replace with function body.
