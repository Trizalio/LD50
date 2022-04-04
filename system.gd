extends Control

onready var PlanetScene = preload("res://planet.tscn")
const TRANSPARENT: Color = Color(1, 1, 1, 0)
const OPAQUE: Color = Color(1, 1, 1, 1)
const SYSTEM_DEFAULT_ZOOM = 0.05
const UNIVERSE_DEFAULT_ZOOM = 200

#const SCREEN_CENTER: Vector2 = Vector2() 

func descend_into_star(map_star):
	print('descend_into_star')
	var universe_map = $universe_map
	var system_map = $system_map
#	universe_map.zoom_camera(1, map_star.position)
#	universe_map.move_camera_to_planet(map_star, 100)
	var zoom_scale = UNIVERSE_DEFAULT_ZOOM
	var camera_center_position = -map_star.position * zoom_scale
	universe_map.zoom_camera(zoom_scale, camera_center_position)
	Animator.animate(
		universe_map, 'modulate', TRANSPARENT, universe_map.zoom_duration, 
		universe_map.zoom_trans, universe_map.zoom_ease
	)
	Animator.animate(
		universe_map, 'visible', false, universe_map.zoom_duration * 2,
		universe_map.zoom_trans, universe_map.zoom_ease
	)
	Animator.animate(
		system_map, 'modulate', OPAQUE, universe_map.zoom_duration, 
		universe_map.zoom_trans, universe_map.zoom_ease
	)
	system_map.zoom_camera(SYSTEM_DEFAULT_ZOOM, system_map.zoom_shift2, 0)
	system_map.zoom_camera(1)
	
func ascend_to_universe():
	print('ascend_to_universe')
	var universe_map = $universe_map
	var system_map = $system_map
	var current_ustar_pos = universe_map.current_planet.position
	system_map.zoom_camera(SYSTEM_DEFAULT_ZOOM, current_ustar_pos)
	Animator.animate(
		system_map, 'modulate', TRANSPARENT, universe_map.zoom_duration, 
		universe_map.zoom_trans, universe_map.zoom_ease
	)
	
	Animator.animate(
		universe_map, 'modulate', OPAQUE, universe_map.zoom_duration, 
		universe_map.zoom_trans, universe_map.zoom_ease
	)
	universe_map.zoom_camera(
		UNIVERSE_DEFAULT_ZOOM, 
		system_map.zoom_shift2 - current_ustar_pos * UNIVERSE_DEFAULT_ZOOM,
		0
	)
	universe_map.visible = true
	universe_map.zoom_camera(1)

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.register_game(self)
	var universe_map = $universe_map
	var ustars = [
		PlanetScene.instance().prepare_ustar(), 
		PlanetScene.instance().prepare_ustar(),
		PlanetScene.instance().prepare_ustar(),
		PlanetScene.instance().prepare_ustar(),
	]
	ustars[0].position = Vector2(100, 100)
	ustars[1].position = Vector2(-150, 70)
	ustars[2].position = Vector2(-110, -130)
	ustars[3].position = Vector2(10, -11)
	universe_map.load_universe(ustars)
	
	var system_map = $system_map
	system_map.modulate = TRANSPARENT
	system_map.zoom_camera(0.0001)
	var planet = PlanetScene.instance()
	planet.prepare_gas_giant()
	var star = PlanetScene.instance()
	star.prepare_star()
	planet.position = Vector2(100, 300)
	system_map.load_system(star, [planet])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_to_starmap_pressed():
	$resources_panel.max_materials += 100
	pass # Replace with function body.
