extends Button

#Get variables for the audio player like source and volume
@export_category("Sounds")
@export var sound:Array[AudioStream] = [
	preload("res://Sounds/Arcade_Button Hover.wav"),	#Hover
	preload("res://Sounds/Arcade_Button.wav"),			#Press
	]
@export var volumeOffset:float = -6

#Create a new AudioPlayer
var audioManager:AudioStreamPlayer = AudioStreamPlayer.new()

#Instantiate it as a new child on the tree and assign the set paths and values on load
func _ready():
	await get_tree().create_timer(0.1).timeout				#Create a minimal timeout on creation, so focus grab for keyboard control doesn´t trigger a sound
	add_child(audioManager)
	audioManager.set_stream(sound[0])						#Assign default sound
	audioManager.set_volume_db(volumeOffset)

#Call play on the AudioManager
func playSound():
	audioManager.play()

func _on_pressed():
	audioManager.set_stream(sound[1])
	playSound()
	
func _on_focus_entered():
	audioManager.set_stream(sound[0])
	playSound()

func _on_mouse_entered():
	audioManager.set_stream(sound[0])
	playSound()
