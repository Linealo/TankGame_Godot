#extends Tank
extends "res://Scripts/MasterTank.gd"

func _on_health_change(value):
	$"../HUD".healthBarUpdateP2(value)				#to update the HUD health for P2
