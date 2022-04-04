extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var game = null

func register_game(game):
	self.game = game

func button_pressed(object, action: String):
	if object.is_ustar:
		game.descend_into_star(object)
	else:
		game.ascend_to_universe()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
