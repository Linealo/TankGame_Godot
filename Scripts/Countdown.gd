extends Label

func _ready():
	var CDbeep:AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(CDbeep)
	CDbeep.set_stream(preload("res://Sounds/Countdown_Beep.wav"))
	CDbeep.play()
	
func _process(delta):
	#self.set_text("var_to_str(time)")
	if get_parent().get_node("StartCD").time_left > 0.5:
		text = str(round(get_parent().get_node("StartCD").time_left))
	elif get_parent().get_node("StartCD").time_left < 0.5:
		text = "GO!"
