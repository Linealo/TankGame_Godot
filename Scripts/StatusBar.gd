#Script for the StatusBar

extends Node2D

class_name StatusBar

var health_3 = preload("res://Graphics/UI/PixelUI_Pack/Health_Separate/Health_3.png")
var health_2 = preload("res://Graphics/UI/PixelUI_Pack/Health_Separate/Health_2.png")
var health_1 = preload("res://Graphics/UI/PixelUI_Pack/Health_Separate/Health_1.png")
var health_0 = preload("res://Graphics/UI/PixelUI_Pack/Health_Separate/Health_0.png")

#function that is continously called in during runtime
func _process(delta): 
	global_rotation = 0	# makes sure the bar stays on top of the player

#Function to set the graphic to the according graphic. THe value is parsed through from the tank on taking damage and loading the game as well as on other health changes
func healthBarUpdate(value):						#function is connceted to signal "healthChnaged" which parses the current health a as value along with it
	if value >= 3:
		$HealthBar.texture_progress = health_3
		#print_debug("Health changed to 3")
	elif value == 2:
		$HealthBar.texture_progress = health_2
		#print_debug("Health changed to 2")
	elif value == 1:
		$HealthBar.texture_progress = health_1
		#print_debug("Health changed to 1")
	elif value <= 0:
		$HealthBar.texture_progress = health_0
		#print_debug("A player died")
	
