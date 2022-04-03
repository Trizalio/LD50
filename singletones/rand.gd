extends Node

var rand = RandomNumberGenerator.new()

func _ready():
	rand.randomize()

func float_in_range(from: float, to: float):
	return rand.randf_range(from, to)
	
func check(chance: float) -> bool:
	return chance >= float_in_range(0, 1)

func choice(options):
	if options == null or len(options) == 0:
		return null
	return options[rand.randi() % options.size()]
