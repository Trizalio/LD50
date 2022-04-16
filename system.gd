extends Control

onready var PlanetScene = preload("res://planet.tscn")
const TRANSPARENT: Color = Color(1, 1, 1, 0)
const OPAQUE: Color = Color(1, 1, 1, 1)
const SYSTEM_DEFAULT_ZOOM = 0.05
const UNIVERSE_DEFAULT_ZOOM = 200

#const SCREEN_CENTER: Vector2 = Vector2() 

func recall_universe_camera():
	$universe_map.recall_camera()

func recall_system_camera():
	$system_map.recall_camera()
	
func set_universe_invisible():
	var universe_map = $universe_map
	if universe_map.current_planet != null:
		universe_map.visible = false

var tracking = null
func track(ustar = null):
	tracking = ustar
	
onready var to_starmap = $to_starmap
func descend_into_star(ustar):
	to_starmap.disabled = false
	universe_map.animate(to_starmap, 'modulate', Color.white)
	print('descend_into_star: ', ustar)
	var universe_map = $universe_map
	var system_map = $system_map
	
	
	var star = PlanetScene.instance()
	star.prepare_star(ustar)
	system_map.load_system(star, GameState.get_planets_by_ustar(ustar))
#	universe_map.zoom_camera(1, map_star.position)
#	universe_map.move_camera_to_planet(map_star, 100)
	var zoom_scale = UNIVERSE_DEFAULT_ZOOM
	var camera_center_position = -ustar.position * zoom_scale
	universe_map.zoom_camera(zoom_scale, camera_center_position)
	universe_map.animate(universe_map, 'modulate', TRANSPARENT)
#	yield(get_tree().create_timer(universe_map.zoom_duration), "timeout")
	get_tree().create_timer(universe_map.zoom_duration).connect("timeout", self, "set_universe_invisible")
#	universe_map.animate(universe_map, 'visible', false, universe_map.zoom_duration * 2)
	system_map.animate(system_map, 'modulate', OPAQUE)
#	Animator.animate(
#		universe_map, 'modulate', TRANSPARENT, universe_map.zoom_duration, 
#		universe_map.zoom_trans, universe_map.zoom_ease
#	)
#	Animator.animate(
#		universe_map, 'visible', false, universe_map.zoom_duration * 2,
#		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
#	)
#	Animator.animate(
#		system_map, 'modulate', OPAQUE, universe_map.zoom_duration, 
#		universe_map.zoom_trans, universe_map.zoom_ease
#	)
#	system_map.zoom_camera(SYSTEM_DEFAULT_ZOOM, Vector2(), 0)
	system_map.zoom_camera(SYSTEM_DEFAULT_ZOOM, system_map.zoom_shift, 0)
#	system_map.zoom_camera(SYSTEM_DEFAULT_ZOOM, system_map.zoom_shift2, 0)
	system_map.recall_camera(1)
	
func ascend_to_universe():
	to_starmap.disabled = true
	universe_map.animate(to_starmap, 'modulate', Color.transparent)
	print('ascend_to_universe')
	var universe_map = $universe_map
	var system_map = $system_map
	var current_ustar_pos = universe_map.current_planet.position
	system_map.recall_camera(SYSTEM_DEFAULT_ZOOM, current_ustar_pos)
	system_map.animate(system_map, 'modulate', TRANSPARENT)
	universe_map.animate(universe_map, 'modulate', OPAQUE)
#	Animator.animate(
#		system_map, 'modulate', TRANSPARENT, system_map.zoom_duration, 
#		system_map.zoom_trans, system_map.zoom_ease
#	)
#
#	Animator.animate(
#		universe_map, 'modulate', OPAQUE, universe_map.zoom_duration, 
#		universe_map.zoom_trans, universe_map.zoom_ease
#	)
	universe_map.zoom_camera(
		UNIVERSE_DEFAULT_ZOOM, 
		universe_map.zoom_shift2 - current_ustar_pos * UNIVERSE_DEFAULT_ZOOM,
		0
	)
#	universe_map.animate(universe_map, 'visible', false, universe_map.zoom_duration * 0.1)
	universe_map.visible = true
	universe_map.recall_camera(1)

var inhabited_zone = null
var ustars = []
func rerender_galaxy():
	var new_inhabited_zone = null
	for star in ustars:
		if star.is_inhibitable or star.ships > 0:
			if new_inhabited_zone == null:
				new_inhabited_zone = Rect2(-star.position, Vector2())
			new_inhabited_zone = new_inhabited_zone.expand(-star.position)
	inhabited_zone = new_inhabited_zone
	universe_map.load_universe(ustars)
	
func start_select_destination(source_ustar):
	universe_map.start_select_destination(source_ustar)
	
func end_select_destination():
	universe_map.end_select_destination()
	
onready var map_controls = $vbox/map_controls
onready var universe_map = $universe_map
onready var map_marks = $map_marks
func hide_map_controls(duration: float = -1):
	if duration < 0:
		duration = universe_map.zoom_duration / 2
	map_controls.hide_(duration)

func show_map_controls(duration: float = -1):
	if duration < 0:
		duration = universe_map.zoom_duration
	map_controls.show_(duration)
		
func on_universe_zoom():
	print('on_universe_zoom')
	hide_map_controls()
	
func on_universe_unzoom():
	print('on_universe_unzoom')
	show_map_controls()

func on_ustar_selected(ustar):
	GameState.ustar_selected(ustar)

func _ready():
	GameState.register_game(self)
#	var universe_map = $universe_map
	universe_map.connect("ustar_selected", self, "on_ustar_selected")
	universe_map.connect("zoom", self, "on_universe_zoom")
	universe_map.connect("unzoom", self, "on_universe_unzoom")
	map_controls.connect("move", self, "on_map_contols_move")
	ustars = GameState.generate_random_ustars()
	
	rerender_galaxy()
#	universe_map.load_universe(ustars)

onready var status_labels = [
	$vbox2/center/status, $vbox2/center2/status, $vbox2/center3/status, 
	$vbox2/center4/status, $vbox2/center5/status
]
#onready var status_label = $vbox2/center/status
func display_status(status: String, index: int = 1):
	var status_label = status_labels[index - 1]
	if status:
#		status_label.visible = true
		universe_map.animate(status_label, 'modulate', Color.white)
		status_label.text = status
	else:
		universe_map.animate(status_label, 'modulate', Color.transparent)
#		status_label.visible = false
		
	
	
onready var confirmation = $confirmation
onready var accept_button = $confirmation/margin/margin/vbox/hbox/accept
onready var back_button = $confirmation/margin/margin/vbox/hbox/back
onready var rich_text = $confirmation/margin/margin/vbox/rich_text
func display_modal(text: String, callback_name: String = '', args: Array = []):
	rich_text.text = text
	confirmation.visible = true
	if callback_name:
		var all_args = [callback_name, args]
		accept_button.connect("pressed", self, "on_accept_pressed", all_args, CONNECT_ONESHOT)
	accept_button.visible = callback_name != ''
	
func on_accept_pressed(callback_name, args):
#	accept_button.disconnect("pressed", self, "on_accept_pressed")
	GameState.callv(callback_name, args)
	confirmation.visible = false
	pass

func on_back_pressed():
	accept_button.disconnect("pressed", self, "on_accept_pressed")
	confirmation.visible = false
#	back_button.disconnect("pressed", self, "on_back_pressed")
#	pass # Replace with function body.
	

onready var move_direction: Vector2 = Vector2()
func on_map_contols_move(direction: Vector2):
	if not universe_map.current_planet:
		move_direction = -direction * 300


func get_range_from_rect(rect: Rect2, point: Vector2) -> Vector2:
	rect = rect.abs()
	var result: Vector2 = Vector2()
	if point.x < rect.position.x:
		result.x = rect.position.x - point.x
	elif point.x > rect.end.x:
		result.x = point.x - rect.end.x
		
	if point.y < rect.position.y:
		result.y = rect.position.y - point.y
	elif point.y > rect.end.y:
		result.y = point.y - rect.end.y
		
	return result

#onready var camera_speed_to_inhibited_planet: Vector2 = Vector2()
func _process(delta):
	if move_direction and not tracking and not universe_map.current_planet:
		universe_map.position += delta * move_direction
		
		
#	if camera_speed_to_inhibited_planet:
#		universe_map.position += delta * camera_speed_to_inhibited_planet
	
		
	if tracking:
		var target_position = Vector2(700, 450) - tracking.position
		var power = 0.1;
		universe_map.position = (target_position * power + universe_map.position) / (1 + power)
	
	if inhabited_zone is Rect2:
		
		var zone: Rect2
		var screen_half = Vector2(700, 450)
		var screen_shift = Vector2(0, 0) * 0;
		var allowed_zone = inhabited_zone.grow_individual(
			screen_half.x, screen_half.y, screen_half.x, screen_half.y)
		var universe_map_center_position = universe_map.position - screen_half - screen_shift
	#	var universe_map_left_border: float = (universe_map_center_position - screen_half).x
	#	if universe_map_left_border > inhabited_zone.end.x:
	#		universe_map_left_border = inhabited_zone.end.x
	#		universe_map_center_position.x = 
	#	print(universe_map_center_position, " -> ", inhabited_zone)
	
#		universe_map_center_position.x = max(universe_map_center_position.x, allowed_zone.position.x)
#		universe_map_center_position.y = max(universe_map_center_position.y, allowed_zone.position.y)
#		universe_map_center_position.x = min(universe_map_center_position.x, allowed_zone.end.x)
#		universe_map_center_position.y = min(universe_map_center_position.y, allowed_zone.end.y)
#		universe_map.position = universe_map_center_position + screen_half + screen_shift

		var range_from_allowed_zone = get_range_from_rect(allowed_zone, universe_map_center_position)
		
#		print(range_from_allowed_zone)
		if range_from_allowed_zone:
			universe_map.position += delta * range_from_allowed_zone

func _on_to_starmap_pressed():
	ascend_to_universe()
#	GameState.
#	$resources_panel.max_materials += 100
	pass # Replace with function body.

