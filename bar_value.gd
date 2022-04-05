extends CenterContainer
tool

export var text: String = "resource" setget set_text
export var cur_value: float = 0 setget set_cur_value

func set_text(new_text: String):
	text = new_text.to_upper()
	var label_node = get_node_or_null("outer/inner/hbox/label")
	if label_node != null:
		label_node.text = text
	
func set_cur_value(new_cur_value):
	cur_value = new_cur_value
	var value_node = get_node_or_null('outer/inner/hbox/value')
	if value_node != null:
		value_node.text = str(int(cur_value))
	
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
