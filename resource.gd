extends MarginContainer
tool

export var text: String = "resource" setget set_text
export var max_value: float = 100 setget set_max_value
export var cur_value: float = 0 setget set_cur_value

func set_text(new_text: String):
	text = new_text.to_upper()
	var label_node = get_node("outer/inner/hbox/label")
	if label_node != null:
		label_node.text = text
	
func set_max_value(new_max_value):
	max_value = new_max_value
	var bar_node = get_node('outer/inner/hbox/center/bar')
	if bar_node != null:
		bar_node.max_value = max_value
	update_value_text()
	
func set_cur_value(new_cur_value):
	cur_value = new_cur_value
	var bar_node = get_node('outer/inner/hbox/center/bar')
	if bar_node != null:
		bar_node.value = cur_value
	update_value_text()
	
func update_value_text():
	var value_node = get_node('outer/inner/hbox/value')
	if value_node != null:
		value_node.text = str(int(cur_value)) + "/" + str(int(max_value))
	
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	set_text(text)
#	set_max_value(max_value)
#	set_cur_value(cur_value)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
