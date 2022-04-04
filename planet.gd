extends Node2D
class_name Planet

signal pressed
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var selection: float = 0 setget set_selection
const anim_duration: float = 0.3
const anim_trans = Tween.TRANS_SINE
const anim_ease = Tween.EASE_IN_OUT
var is_ustar: bool = false
var sprite: Sprite = null
var title: String

func set_selection(new_selection: float):
	sprite.material.set_shader_param("selection_gap", new_selection)
	selection  = new_selection

# Called when the node enters the scene tree for the first time.
func _ready():
	title = "planet tau"
#	$sprite.material = $sprite.material.duplicate()
	pass # Replace with function body.

func _prepare_any():
	sprite.visible = true
	sprite.material = sprite.material.duplicate()

func prepare_star():
	sprite = $star_sprite
	_prepare_any()
	return self
	
func prepare_gas_giant():
	sprite = $planet_sprite
	_prepare_any()
	return self
	
func prepare_ustar():
	is_ustar = true
	sprite = $ustar_sprite
	_prepare_any()
	return self
	

func _process(delta):
#	$sprite.material.set_shader_param("shrink", target_shrink)
	pass

func animate_selection(target_value: float):
	Animator.animate(self, "selection", target_value, anim_duration, anim_trans, anim_ease)

func _on_mouse_entered():
	animate_selection(0.05)
	print('mouse_entered')
#	var tween = get_node("tween")
#	tween.interpolate_property(self, "selection", selection, 0.05, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#	tween.start()


func _on_mouse_exited():
	animate_selection(0)
#	var tween = get_node("tween")
#	tween.interpolate_property(self, "selection", selection, 0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#	tween.start()
	pass # Replace with function body.


func _on_Button_pressed():
	emit_signal("pressed")
#	print('pressed')
#	pass # Replace with function body.
