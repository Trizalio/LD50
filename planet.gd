extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var selection: float = 0 setget set_selection

func set_selection(new_selection: float):
	$sprite.material.set_shader_param("selection_gap", new_selection)
	selection  = new_selection

# Called when the node enters the scene tree for the first time.
func _ready():
	$sprite.material = $sprite.material.duplicate()
	pass # Replace with function body.


func _process(delta):
#	$sprite.material.set_shader_param("shrink", target_shrink)
	pass


func _on_mouse_entered():
	print('mouse_entered')
	var tween = get_node("tween")
	tween.interpolate_property(self, "selection", selection, 0.05, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()


func _on_mouse_exited():
	var tween = get_node("tween")
	tween.interpolate_property(self, "selection", selection, 0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	pass # Replace with function body.


func _on_Button_pressed():
	print('pressed')
	pass # Replace with function body.
