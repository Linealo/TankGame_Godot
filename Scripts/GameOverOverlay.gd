extends Control

func _ready():
	$VBoxContainer/Restart.grab_focus()
	
func _process(delta):
	#print(get_parent().is_visible)
	pass

func _on_restart_pressed():
	get_parent().hide()
	get_tree().paused = false 											#Unpause the tree to inputs can be read again
	get_tree().change_scene_to_file("res://Scenes/World.tscn")			#Get the node tree of this project and change to the game scene again, effectivly reloading it.

func _on_main_menu_pressed():
	get_parent().hide()
	get_tree().paused = false											#Unpause the tree to inputs can be read again
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")		#Get the node tree of this project and change to the MainMenu
