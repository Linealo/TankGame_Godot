extends Node2D

@onready var tank_p1 = preload("res://Scenes/Tank_P1.tscn")
@onready var tank_p2 = preload("res://Scenes/Tank_P2.tscn")
#@onready var tank_p3 = preload("res://Tanks/Tank_P3.tscn")
#@onready var tank_p4 = preload("res://Tanks/Tank_P4.tscn")
@export var enableStartScreen = false

func _ready():
	print("Game started")
	#Ready variable to decide if the start screen before the game should show or not
	if enableStartScreen:
		handleStartScreen()
	else:
		$StartScreen.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)			#Hide the cursour during gameplay

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
