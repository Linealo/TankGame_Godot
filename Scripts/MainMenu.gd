#Main Menu controls for the UI
#Button calls are made through the internal signals that come with the buttons

extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)						#Bring back the cursor on the menu screen
	$MainMenu/VBoxContainer/Start.grab_focus()							#Grabs focus of the Start Buttons as the custom selected entity to make it controlable with the keyboard

func _process(delta):
	if not $MenuMusic.is_playing():
		$MenuMusic.play()
	if Input.is_action_just_pressed("Back"):							#Go back to menu if escape or backspace is pressed
		returnToMM()

func _on_start_pressed():												#Signal listening to the Start Button being pressed
	get_tree().change_scene_to_file("res://Scenes/World.tscn")			#Get the node tree of this project and change to the game scene.
	#Will later instead make the cursor jump to a Game Settings Menu for Mode, Player, Map and Rule select

func _on_options_pressed():												#Signal listening to the Options Button being pressed
	pass # Replace with function body.									#opens the options menu screen scene, hiding the current menu

func _on_credits_pressed():												#Signal listening to the Credits Button being pressed
	if not $Credits.visible:
		$Credits.show()
		$Credits/BackToMainMenu.grab_focus()
	if $MainMenu.visible:
		$MainMenu.hide()

func _on_quit_pressed():												#Signal listening to the Quit Button being pressed
	get_tree().quit()													#Quits the game

func _on_back_to_main_menu_pressed():									#Back to Menu button
	returnToMM()

func returnToMM():														#Function that return to the mainMenu 
	if $Credits.visible:
		$Credits.hide()
	if not $MainMenu.visible:
		$MainMenu.show()
		$MainMenu/VBoxContainer/Start.grab_focus()



