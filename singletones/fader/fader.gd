extends Node

signal faded_in
signal faded_out

func _ready():
	pass # Replace with function body.

func fade(fade_in_time: float = 0.5, fade_out_time: float = 0.5):
	var forward_speed = 1 / fade_in_time
	var backward_speed = 1 / fade_out_time
	$animation.play('fade', -1, forward_speed, false)
	yield(self, 'faded_in')
	$animation.play('fade', -1, -backward_speed, true)
	
func _animation_end():
	emit_signal("faded_in")
	
func _animation_start():
	emit_signal("faded_out")
	
func is_fading():
	return $animation.is_playing()
