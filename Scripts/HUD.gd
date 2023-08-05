extends Control

@export_category("Health graphics")
@export var health_3 = preload("res://Graphics/UI/PixelUI_Pack/Health_Separate/Health_3.png")
@export var health_2 = preload("res://Graphics/UI/PixelUI_Pack/Health_Separate/Health_2.png")
@export var health_1 = preload("res://Graphics/UI/PixelUI_Pack/Health_Separate/Health_1.png")
@export var health_0 = preload("res://Graphics/UI/PixelUI_Pack/Health_Separate/Health_0.png")

func healthBarUpdateP1(value):						#function is connceted to signal "healthChnaged" which parses the current health a as value along with it
	if value >= 3:
		$P1_HUD/P1_Health.set_texture(health_3)
		#print_debug("Health changed to 3")
	elif value == 2:
		$P1_HUD/P1_Health.set_texture(health_2)
		#print_debug("Health changed to 2")
	elif value == 1:
		$P1_HUD/P1_Health.set_texture(health_1)
		#print_debug("Health changed to 1")
	elif value <= 0:
		$P1_HUD/P1_Health.set_texture(health_0)
		#print_debug("A player died")

func healthBarUpdateP2(value):						#function is connceted to signal "healthChnaged" which parses the current health a as value along with it
	if value >= 3:
		$P2_HUD/P2_Health.set_texture(health_3)
		#print_debug("Health changed to 3")
	elif value == 2:
		$P2_HUD/P2_Health.set_texture(health_2)
		#print_debug("Health changed to 2")
	elif value == 1:
		$P2_HUD/P2_Health.set_texture(health_1)
		#print_debug("Health changed to 1")
	elif value <= 0:
		$P2_HUD/P2_Health.set_texture(health_0)
		#print_debug("A player died")
