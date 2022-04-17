extends GridContainer

signal move(direction)

var should_be_hidden: bool = false
const zoom_trans = Tween.TRANS_SINE
const zoom_ease = Tween.EASE_IN_OUT

func _set_visible(value):
	if value == true:
		self.visible = value
	elif should_be_hidden:
		self.visible = value

func animate(object: Object, property: NodePath, final_val, duration: float = -1, delete: bool = false):
	Animator.animate(object, property, final_val, duration, zoom_trans, zoom_ease, delete)


func hide_(duration: float, zoom_trans = Tween.TRANS_SINE, zoom_ease = Tween.EASE_IN_OUT):
	should_be_hidden = true
	Animator.animate(self, 'modulate', Color.transparent, duration, zoom_trans, zoom_ease)
	get_tree().create_timer(duration).connect("timeout", self, "_set_visible", [false])

func show_(duration: float, zoom_trans = Tween.TRANS_SINE, zoom_ease = Tween.EASE_IN_OUT):
	should_be_hidden = false
	Animator.call_delayed(self, 'animate', duration / 2, self, 'modulate', Color.white, duration / 2)
#	Animator.animate(self, 'modulate', Color.white, duration / 2, zoom_trans, zoom_ease)
	get_tree().create_timer(duration / 2).connect("timeout", self, "_set_visible", [true])
	
func _on_mouse_exited():
	self.emit_signal('move', Vector2())

func _on_mouse_entered(direction: Vector2):
	self.emit_signal('move', direction)
