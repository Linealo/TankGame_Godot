#extends Tank
extends "res://Scripts/MasterTank.gd"

func _on_health_change(value):
	$"../HUD".healthBarUpdateP1(value)				#to update the HUD health for P1
