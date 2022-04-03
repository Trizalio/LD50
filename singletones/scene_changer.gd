extends Node

signal scene_changed

var current_scene = null

var Fader = preload("res://singletones/fader/fader.tscn")
var fader = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	fader = Fader.instance()
	root.call_deferred('add_child', fader)
#	get_node("/root").add_child(resourse_bars)

func goto_scene(path, fade_in_time: float = 0.2, fade_out_time: float = 0.2):
	if is_changing_scene():
		return
	print('change scene to:', path)
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.
	
	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	
	fader.fade(fade_in_time, fade_out_time)
	AudioManager.fade_in()
	yield(fader, 'faded_in')
#	yield(get_tree().create_timer(fade_in_time), "timeout")
	call_deferred("_deferred_goto_scene", path)

func is_changing_scene():
	return fader.is_fading()

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()
	
	# Load the new scene.
	var s = ResourceLoader.load(path)
	
	# Instance the new scene.
	current_scene = s.instance()
	
	# Add it to the active scene, as child of root.
	var root = get_tree().get_root()
	root.add_child(current_scene)
	root.move_child(current_scene, 0)
	
	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	AudioManager.fade_out()
	print('scene changed to: ', current_scene, '(', path, ')')
	emit_signal("scene_changed")
