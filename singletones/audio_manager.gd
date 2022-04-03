extends Node


var player: AudioStreamPlayer = null
var tween: Tween = null
var volume_db: float = 0
const min_volume_db = -80

func _ready():
	print('AudioManager._ready')
	tween = Tween.new()
	player = AudioStreamPlayer.new()
	self.add_child(player)
	self.add_child(tween)

func play_this(new_stream: AudioStream, new_volume_db: float = 0):
	print('play_this:', new_stream)
	player.stream = new_stream
	volume_db = new_volume_db
	player.volume_db = volume_db
	player.play()

func fade_in(duration: float = 1.5):
	tween.remove_all()
	tween.interpolate_property(player, "volume_db", null, min_volume_db, 
		duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	
func fade_out(duration: float = 1.5):
	tween.remove_all()
	tween.interpolate_property(player, "volume_db", null, volume_db, 
		duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
