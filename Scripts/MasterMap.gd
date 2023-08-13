extends Node2D

#@onready var tank_p1 = preload("res://Scenes/Tank_P1.tscn")
#@onready var tank_p2 = preload("res://Scenes/Tank_P2.tscn")
#@onready var tank_p3 = preload("res://Tanks/Tank_P3.tscn")
#@onready var tank_p4 = preload("res://Tanks/Tank_P4.tscn")
@onready var P1 = $Game/Tank_P1
@onready var P2 = $Game/Tank_P2
#var P3
#var P4
@export var enableStartScreen = false

#Map selector settings - enable randomisation or turn it off
@export var randomiseMap = false						#Toggle for randomisation
var RNGMapNr:int  								#Storage for random number within the array of Maps

enum Maps {												#List of maps
	Forest,			#0
	City,			#1
	Dungeon,		#2
	Kyst,			#3
}
@export var selectedMap: Maps							#Map selector for inspector if one wants to overwrite
@export var mapScenes: Array[PackedScene] = [			#Add Maps in here or through inspector
	preload("res://Scenes/Map_Forest.tscn"),			#Map 0 - Forest - Classic Battle Map
	preload("res://Scenes/Map_City.tscn"),				#Map 1 - City - Big field, small passages
	preload("res://Scenes/Map_Dungeon.tscn"),			#Map 2 - Dungeon - Welcome to the dark
	preload("res://Scenes/Map_Kyst.tscn")				#Map 3 - Coastal - Open fire and few places to hide
]
signal MapLoaded

func _ready():	
	print("Game started")
	
	RNGMapNr = randi() % mapScenes.size()				#create a random number within the index length of the mapScenes array
	selectMap() #And place players
	
	#Ready variable to decide if the start screen before the game should show or not
	if enableStartScreen:
		handleStartScreen()
	else:
		$StartScreen.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)			#Hide the cursour during gameplay
	
		
##Map Selector	
#The selected map will be added as a child of the $Game CanvasLayer and have the name "WorldMap"
#The powerUpSpawner has a function, that will attempt to read an Array within the WorldMap node, to determine where it can spawn powerUps
func selectMap():
	#If no randomisation is enabled, instantiate a map with the chosen enum position as the index of the map list array
	if not randomiseMap:
		var WorldMap = mapScenes[selectedMap].instantiate()
		get_node("Game").add_child(WorldMap)
		get_node("Game").move_child(WorldMap, 0)								#move the child to the right render posiition
	#If randomisation is enabled, instantiate a map with a ranodm inced
	if randomiseMap:
		#If RNG is enabled, the selectedMap carrying the index for the array, will be overwritten by the random number
		selectedMap = RNGMapNr					
		var WorldMap = mapScenes[RNGMapNr].instantiate()
		get_node("Game").add_child(WorldMap)
		get_node("Game").move_child(WorldMap, 0)
	emit_signal("MapLoaded")
	#Asjut players to map - only execute after Map has been loaded, thus positioned here
	placePlayers()
	
##Places players and handles their features for this round
func placePlayers():	
	#Get the starting positions and rotations from the maps and place the players there 
	$Game/Tank_P1.global_position = $Game/WorldMap/P1_Start.global_position
	$Game/Tank_P1.rotation = $Game/WorldMap/P1_Start.rotation
	$Game/Tank_P2.global_position = $Game/WorldMap/P2_Start.global_position
	$Game/Tank_P2.rotation = $Game/WorldMap/P2_Start.rotation

	#Map specific changes
	if selectedMap == 1: #On the chity map
		$Game/Tank_P1.set_scale(Vector2(0.07,0.07))
		$Game/Tank_P1.moveSpeed = 180
		$Game/Tank_P1.bulletSpeed = 600
		$Game/Tank_P2.set_scale(Vector2(0.07,0.07))
		$Game/Tank_P2.moveSpeed = 180
		$Game/Tank_P2.bulletSpeed = 600
		$Game/PowerUpSpawner.powerUpScale = 0.7
		
	if selectedMap == 2: #Dungeon Map
		$Game/Tank_P1/DungeonLight.show()
		$Game/Tank_P2/DungeonLight.show()
		$Game/PowerUpSpawner.spawnDelay = 10
		$Game/PowerUpSpawner.spawnChance = 500
	else:
		$Game/Tank_P1/DungeonLight.hide()
		$Game/Tank_P2/DungeonLight.hide()
		
	if selectedMap == 3:
		$Game/Tank_P1.moveSpeed = 180
		$Game/Tank_P1.set_scale(Vector2(0.07,0.07))
		$Game/Tank_P1/DungeonLight.show()
		$Game/Tank_P2.moveSpeed = 180
		$Game/Tank_P2.set_scale(Vector2(0.07,0.07))
		$Game/Tank_P2/DungeonLight.show()
		$Game/PowerUpSpawner.powerUpScale = 0.7

##Handles the potential start screen that could show up at the beginning of a game. Includes a countdown
func handleStartScreen():
	#Show the Start Screen based on the pause screen overaly
	$StartScreen.show()
	#Disable a few pause screen items to create the start screen
	$StartScreen/StartScreen/Main.hide()
	$StartScreen/StartScreen/BG.hide()
	$StartScreen/StartScreen/InnerBG.hide()
	#Pause the game on the Start Screen and wait 10 seconds to let the start countdown to hit 0
	get_tree().paused = true
	await get_tree().create_timer(11).timeout
	#Unpause the game if the real pause screen isn´t visible 
	if not $Pause/PauseMenu.is_visible():
		get_tree().paused = false
	#Remove the Start Screen fully from the scene
	$StartScreen.queue_free()
	
func _on_level_music_intro_finished():
	$LevelMusicLoop.play()

func _on_tank_p_1_player_died():
	$GameOver/GameOverOverlay/Winner.text = "Player 2 won!"

func _on_tank_p_2_player_died():
	$GameOver/GameOverOverlay/Winner.text = "Player 1 won!"
