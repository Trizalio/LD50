extends Node

class AnimationStep:
	var start_val = null
	var final_val = null
	var duration = null
	var trans_type = null
	var ease_type = null
	var property = null
	
	func _init(_final_val, _duration: float, _start_val=null, _trans_type=null, _ease_type=null):
		start_val = _start_val
		final_val = _final_val
		duration = _duration
		trans_type = _trans_type
		ease_type = _ease_type
		property = null
		
class DefferedCall:
	var delay = null
	var callback = null
	var arg1 = null
	var arg2 = null
	var arg3 = null
	var arg4 = null
	var arg5 = null
	
	func _init(_delay: float, _callback: String, _arg1 = null, _arg2 = null, _arg3 = null, _arg4 = null, _arg5 = null):
		delay = _delay
		callback = _callback
		arg1 = _arg1
		arg2 = _arg2
		arg3 = _arg3
		arg4 = _arg4
		arg5 = _arg5


func multi_animate(object: Object, property: NodePath, animation_steps: Array, 
					trans_type, ease_type, destroy=false):
	var tween = Tween.new()
	self.add_child(tween)
	tween.connect("tween_completed", self, '_tween_callback', [tween, animation_steps, trans_type, ease_type, destroy])
	_tween_callback(object, property, tween, animation_steps, trans_type, ease_type, destroy)
	
func _tween_callback(object, property, tween: Tween, animation_steps: Array, 
					trans_type, ease_type, destroy: bool):
	if not animation_steps:
		self.remove_child(tween)
		if destroy:
#			print("destroy: ", object)
			var parent = object.get_parent()
			if parent != null:
				parent.remove_child(object)
		return
	var current_step = animation_steps[0]
	animation_steps.remove(0)
	if current_step is AnimationStep:
		var start_val = current_step.start_val
		if start_val == null:
			start_val = object.get(property)
		if current_step.trans_type != null:
			trans_type = current_step.trans_type
		if current_step.ease_type != null:
			ease_type = current_step.ease_type
		if current_step.property != null:
			property = current_step.property
		tween.interpolate_property(object, property, start_val, 
			current_step.final_val, current_step.duration, trans_type, ease_type)
	if current_step is DefferedCall:
		tween.interpolate_callback(object, current_step.delay, current_step.callback,
			current_step.arg1, current_step.arg2, current_step.arg3, 
			current_step.arg4, current_step.arg5)
	tween.start()

func animate(object: Object, property: NodePath, final_val, duration: float, trans_type, ease_type, destroy=false):
	multi_animate(object, property, [AnimationStep.new(final_val, duration)], trans_type, ease_type, destroy)

func call_delayed(object: Object, callback: String, delay: float, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null):
	var call_ = DefferedCall.new(delay, callback, arg1, arg2, arg3, arg4, arg5)
	multi_animate(object, '', [call_], null, null, false)
	
#bool interpolate_callback(object: Object, duration: float, callback: String, arg1: Variant = null, arg2: Variant = null, arg3: Variant = null, arg4: Variant = null, arg5: Variant = null)

#
#
#func remove_with_delay(object: Object, delay: float):
#	var tween = Tween.new()
#	self.add_child(tween)
#	tween.interpolate_callback(self, delay, 'remove', tween)
#	tween.start()
#	print('call with delay')
#
#func remove(object: Node, tween: Tween):
#	object.get_parent().remove_child(object)
#	self.remove_child(tween)
#	print('called')
