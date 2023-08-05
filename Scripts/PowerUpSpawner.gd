extends Node2D

class_name PowerUpSpawner

#Decalrations
@export var PowerUpCollection: PackedScene
@export var spawnDelay = 20						#Delay between Spawns minimum in seconds
@export var spawnChance = 300					#SpawnChance, lower number = higher spawn rate, 0 == 100%
@export var powerUpScale = 1					#Scaling applied to the powerup on spawn

#Create two random numbers that will be compared
var rNr1: int
var rNr2: int

var VPW = ProjectSettings.get_setting("display/window/size/viewport_width")
var VPH = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready():
	$SpawnDelay.set_wait_time(spawnDelay)										#Set up the timer with the exported value
	if $SpawnDelay.is_stopped() && $SpawnDelay.get_wait_time() > 0:				#make sure the timer starts if its stopped but its value is greater than 0
		$SpawnDelay.start()														#start the timer

func _process(delta):
	calcRandoms()
	spawnPowerUp()

func calcRandoms():
	#Create the values for both random numbers (every franme, because it´s in _process()). Snap them to full int values.
	#This way the random numbers change every frame the cooldown has passed by
	if $SpawnDelay.is_stopped():
		rNr1 = snapped(randf_range(0, spawnChance),1)
		rNr2 = snapped(randf_range(0, spawnChance),1)

#Function to instantiate the PowerUp
func spawnPowerUp():
	if rNr1 == rNr2 && $SpawnDelay.is_stopped():				#if both random numbers match and the SpawnDelayTimer is stopped (has reached 0)
		var powerUp = PowerUpCollection.instantiate()			#instantiate a new powerup
		add_child(powerUp)										#add the powerup as a child to the spawner
		powerUp.set_scale(Vector2(powerUpScale,powerUpScale))	#Force default scale on creation - Can be altered later elsewhere by calling upon powerUpSpawner.PowerUpScale
		powerUp.global_position = Vector2(randf_range(200, VPW - 200),randf_range(200, VPH - 200))
		$SpawnDelay.start()										#restart the delay timer
