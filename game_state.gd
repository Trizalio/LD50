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

func get_hint_for_object(object):
	return 'Object hint'

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
	
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
