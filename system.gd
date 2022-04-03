extends Control

onready var PlanetScene = preload("res://planet.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var system_map = $system_map 
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
