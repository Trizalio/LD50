extends Node2D

class Research:
	var title = null
	var description = null
	var cost = null
	var requirements = null
	export var tier: int = -1 setget , get_tier
	var discovering: float = 0
	var selection: float = 0
	var button = null
	
	func calculate_tier() -> int:
		var result = 0
		for req in self.requirements:
			result = max(result, req.tier + 1)
		
		return result
	
	func get_tier():
		if tier == -1:
			tier = calculate_tier()
		return tier
			
	
	func _init(_title: String, _description: String, _cost: int, _requirements: Array):
		title = _title
		description = _description
		cost = _cost
		requirements = _requirements
		button = Button.new()
		button.grow_horizontal = Control.GROW_DIRECTION_BOTH
		button.text = title
		button.flat = true
		# TODO: Font
#		button.rect_min_size = Vector2(50, 50)


onready var buttons = $buttons
#var researches: Array = []
var tier_to_researches: Dictionary = {}
func add_research(research: Research):
	var tier = research.tier
	var researches = tier_to_researches.get(tier, [])
	tier_to_researches[tier] = researches
	researches.append(research)
	buttons.add_child(research.button)
	place_researches()
	
const y_per_tier = 100
const x_per_research = 100
func place_researches():
	var y = y_per_tier * (len(tier_to_researches) + 1) / 2
	for tier in len(tier_to_researches):
		y -= y_per_tier
		var researches = tier_to_researches[tier]
		var x = -x_per_research * (len(researches) + 1) / 2
		for res in researches:
			x += x_per_research
			res.button.rect_position = Vector2(x, y)
			res.button.rect_position.x -= res.button.rect_size.x / 2
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var r1 = Research.new("Storage", "Allows to build storages on dwarf planets", 2, [])
	var r2 = Research.new("Launchpad", "Allows to build launchpad on dwarf planets\n" +
		"which increase range of ships, flying from it", 2, [])
	var r3 = Research.new(
		"Ark ship refinery", 
		"Allows to gather materials from dwarf planets in systems with ark ship", 
		2, [r1]
	)
	add_research(r1)
	add_research(r2)
	add_research(r3)
	pass_researches_to_shader()
#	researches = [r1, r2, r3]
#	print(r1.tier)
#	print(r2.tier)
#	print(r3.tier)

const shader_scale = 22 * 64 / 2
func pack(value: float) -> float:
	return value / shader_scale / 2 + 0.5

onready var sprite = $sprite
func pass_researches_to_shader():
	var researches_data = []
	var research_connections_data = []
#	var tier_to_amount: Dictionary = {}
	for tier in len(tier_to_researches):
		var researches = tier_to_researches[tier]
		for res in researches:
			researches_data.append(Color(
				pack(res.button.rect_position.x + res.button.rect_size.x / 2), 
				pack(res.button.rect_position.y + res.button.rect_size.y / 2), 
				pack(res.discovering),  pack(res.selection)
			))
			var connections = []
			for tier2 in len(tier_to_researches):
				var researches2 = tier_to_researches[tier2]
				for res2 in researches2:
					var c = Color(0, 0, 0, 0)
					if res.requirements.find(res2) != -1:
						c.r = 1
					connections.append(c)
			
			research_connections_data.append(connections)
	print(research_connections_data)
	if len(researches_data):
		var researches_texture = ShaderTools.make_texture(researches_data)
		var research_connections_texture = ShaderTools.make_texture2(research_connections_data)
		sprite.material.set_shader_param("researches", researches_texture)
		sprite.material.set_shader_param("research_connections", research_connections_texture)
	sprite.material.set_shader_param("researches_amount", len(researches_data))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
