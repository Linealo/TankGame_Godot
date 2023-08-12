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

#Get viewport dimensions (Scrap later in favour of fixed positions)
var VPW = ProjectSettings.get_setting("display/window/size/viewport_width")
var VPH = ProjectSettings.get_setting("display/window/size/viewport_height")

var spawnPositions:Array[Vector2]				#Get´s the array from the WorldMap node that is loaded in. Get´s filled on map load
var chosenSpawnPositionIndex:int				#An index pointing to the position within the array of possible positions - created randomly based on array length
var chosenSpawnPosition:Vector2					#the position chosen
var posBlacklist:Array


func _ready():
	$SpawnDelay.set_wait_time(spawnDelay)										#Set up the timer with the exported value
	if $SpawnDelay.is_stopped() && $SpawnDelay.get_wait_time() > 0:				#make sure the timer starts if its stopped but its value is greater than 0
		$SpawnDelay.start()														#start the timer

func _process(delta):
	$SpawnDelay.set_wait_time(spawnDelay)										#If the spawnDelay is updated for any reason, update the wait time as well
	calcRandoms()
	spawnPowerUp()

##Calculate some Randoms
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
		chooseSpawnPosition()									#choose a random spawn Position
		powerUp.global_position = chosenSpawnPosition			#Place the child at the randomized position
		#powerUp.global_position = Vector2(randf_range(200, VPW - 200),randf_range(200, VPH - 200)) #OLD version with viewport coordinates
		$SpawnDelay.start()										#restart the delay timer

func chooseSpawnPosition():
	#Shorter version - RAM optimised 
	chosenSpawnPosition = spawnPositions[randi() % spawnPositions.size()]
	while chosenSpawnPosition in posBlacklist:
		chosenSpawnPosition = spawnPositions[randi() % spawnPositions.size()]
	
	if posBlacklist.size() >= (spawnPositions.size() - 5):
		posBlacklist.pop_front()
	posBlacklist.append(chosenSpawnPosition)
	
	return chosenSpawnPosition

#Old blaclist checking and randomisation
	#Chooses a spawnposition on random from the list of possible spawnLocations
#	chosenSpawnPositionIndex = randf_range(0, spawnPositions.size())			#First creates a random int within the length of the positions array
#	chosenSpawnPosition = spawnPositions[chosenSpawnPositionIndex]				#then uses that index to get a Vector2 out of the possible locations Array
#	blackListCheck()


##Check the blaclist
#func blackListCheck():
#	for pos in posBlacklist:					#Go through it
#		if chosenSpawnPositionIndex == pos:		#If the chosen position is in it
#			chooseSpawnPosition()				#reroll the position selection
#			return								#and return without further action
#	blackListUpdate()							#if the check returned without hitting true, update the blacklist
#
##Update the blackList accordingly
#func blackListUpdate():
#	#if the blacklist is larger than the possible amount of positions -5 items, remove the oldest and add the new one
#	if posBlacklist.size() >= (spawnPositions.size() - 5):
#		posBlacklist.pop_front()
#		posBlacklist.append(chosenSpawnPositionIndex)
#	#otherwise just add the chosen position
#	else:
#		posBlacklist.append(chosenSpawnPositionIndex)

func _on_world_map_loaded():
	spawnPositions = get_parent().get_node("WorldMap").markerPositions
	#print(spawnPositions.size())
