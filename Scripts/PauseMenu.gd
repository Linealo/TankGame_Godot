extends Control

func _process(delta):
	pauseHandling()
	musicHandling()
	
func pauseHandling():
	#toggle pause menu
	if Input.is_action_just_pressed("Pause"):								#When Pause key is hit
		if self.is_visible():					
			closePauseMenu()									
		elif not get_parent().get_parent().get_node("GameOver").is_visible():	#Only open pause when the GameOver Screen is NOT visible
			openPauseMenu()
	else:
		return									
	
func openPauseMenu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true	
	show()
	$PauseMusic.play()
	$Main/VBoxContainer2/VBoxContainer/Continue.grab_focus()
	
func closePauseMenu():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)	
	if not get_parent().get_parent().get_node("StartScreen"):					#Don´t unpause the tree if the StartScreen is still loaded but still close the pause menu
		get_tree().paused = false
	hide()		
	$PauseMusic.stop()
	
func musicHandling():
	if is_visible() && not $PauseMusic.is_playing():
		$PauseMusic.play()

func _on_continue_pressed():
	closePauseMenu()

func _on_options_pressed():
	if not $Options.visible:
		$Options.show()
		$Main/VBoxContainer2/VBoxContainer/Options.hide()
		$Main/VBoxContainer2/VBoxContainer/Controls.show()
		$Main/VBoxContainer2/VBoxContainer/Controls.grab_focus()
	if $Controls.visible:
		$Controls.hide()
		
func _on_controls_pressed():
	if not $Controls.visible:
		$Controls.show()
		$Main/VBoxContainer2/VBoxContainer/Options.show()
		$Main/VBoxContainer2/VBoxContainer/Controls.hide()
		$Main/VBoxContainer2/VBoxContainer/Options.grab_focus()
	if $Options.visible:
		$Options.hide()

#back to Main Menu - Always close Menu and force unpause of tree
func _on_main_menu_pressed():
	closePauseMenu()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	

