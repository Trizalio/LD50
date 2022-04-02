extends MarginContainer


export var max_materials: float = 100 setget set_max_materials
export var cur_materials: float = 100 setget set_cur_materials

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
	


# Called when the node enters the scene tree for the first time.
func _ready():
	set_max_materials(max_materials)
	set_cur_materials(cur_materials)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
