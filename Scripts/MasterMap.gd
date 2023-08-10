extends Node2D

@onready var tank_p1 = preload("res://Scenes/Tank_P1.tscn")
@onready var tank_p2 = preload("res://Scenes/Tank_P2.tscn")
#@onready var tank_p3 = preload("res://Tanks/Tank_P3.tscn")
#@onready var tank_p4 = preload("res://Tanks/Tank_P4.tscn")
@export var enableStartScreen = false

#Map selector settings - enable randomisation or turn it off
@export var randomiseMap = false						#Toggle for randomisation
@onready var RNGMapNr: int = randf_range(0,2) 			#Storage for random number within the list of Maps

enum Maps {												#List of maps
	Forest,			#0
	City,			#1
	Beach,			#2
}
@export var selectedMap : Maps							#Map selector for inspector if one wants to overwrite
@export var mapScene: Array[PackedScene] = [			#Add Maps in here or through inspector
	preload("res://Scenes/Map_Forest.tscn"),			#Map 0 - Forest
	
]
signal MapLoaded

func _ready():
	print("Game started")
	selectMap()
	
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
		var WorldMap = mapScene[selectedMap].instantiate()
		get_node("Game").add_child(WorldMap)
		get_node("Game").move_child(WorldMap, 0)								#move the child to the right render posiition
	#If randomisation is enabled, instantiate a map with a ranodm inced
	if randomiseMap:
		var WorldMap = mapScene[RNGMapNr].instantiate()
		get_node("Game").add_child(WorldMap)
		get_node("Game").move_child(WorldMap, 0)
	emit_signal("MapLoaded")
	
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
