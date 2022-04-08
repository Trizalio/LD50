extends GridContainer

signal move(direction)

var should_be_hidden: bool = false
const zoom_trans = Tween.TRANS_SINE
const zoom_ease = Tween.EASE_IN_OUT

func _set_invisible():
	if should_be_hidden:
		self.visible = false

func hide_(duration: float, zoom_trans = Tween.TRANS_SINE, zoom_ease = Tween.EASE_IN_OUT):
	should_be_hidden = true
	Animator.animate(self, 'modulate', Color.transparent, duration, zoom_trans, zoom_ease)
	get_tree().create_timer(duration).connect("timeout", self, "_set_invisible")

func show_(duration: float, zoom_trans = Tween.TRANS_SINE, zoom_ease = Tween.EASE_IN_OUT):
	should_be_hidden = false
	Animator.animate(self, 'modulate', Color.white, duration, zoom_trans, zoom_ease)
	self.visible = true
	
func _on_mouse_exited():
	self.emit_signal('move', Vector2())

func _on_mouse_entered(direction: Vector2):
	self.emit_signal('move', direction)
