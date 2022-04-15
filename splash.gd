extends MarginContainer

func _ready():
#	AudioManager.play_this($background.stream, $background.volume_db)
	pass

func _on_start_pressed():
	print('goto')
	SceneChanger.goto_scene('res://system.tscn', 0.5, 0.5)


#Courage Endures
#Trevor Kowalski
# • 
#Courage Endures
# • 
#2019
