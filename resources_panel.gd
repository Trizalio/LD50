extends MarginContainer


export var max_materials: float = 100 setget set_max_materials
export var cur_materials: float = 100 setget set_cur_materials

export var max_energy: float = 100 setget set_max_energy
export var cur_energy: float = 100 setget set_cur_energy

export var cur_year: int = 2000 setget set_cur_year
export var cur_population: int = 10 setget set_cur_population

func set_max_materials(new_max_materials: float):
	max_materials = new_max_materials
	var resource_node = get_node("inner/resources/materials")
	if resource_node != null:
		resource_node.max_value = max_materials
	
func set_cur_materials(new_cur_materials: float):
	cur_materials = new_cur_materials
	var resource_node = get_node("inner/resources/materials")
	if resource_node != null:
		resource_node.cur_value = cur_materials

func set_max_energy(new_max_energy: float):
	max_energy = new_max_energy
	var resource_node = get_node("inner/resources/energy")
	if resource_node != null:
		resource_node.max_value = max_energy
	
func set_cur_energy(new_cur_energy: float):
	cur_energy = new_cur_energy
	var resource_node = get_node("inner/resources/energy")
	if resource_node != null:
		resource_node.cur_value = cur_energy
	
func set_cur_population(new_population: int):
	cur_population = new_population
	var node = get_node("inner/resources/population")
	if node != null:
		node.cur_value = cur_population
	
func set_cur_year(new_year: int):
	cur_year = new_year
	var node = get_node("inner/resources/year")
	if node != null:
		node.cur_value = cur_year
	


# Called when the node enters the scene tree for the first time.
func _ready():
	set_max_materials(max_materials)
	set_cur_materials(cur_materials)
	GameState.register_panel(self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
