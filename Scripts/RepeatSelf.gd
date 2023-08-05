extends AudioStreamPlayer

func _process(delta):
	repeatMusic()

func repeatMusic():
	if not self.is_playing:
		play()
