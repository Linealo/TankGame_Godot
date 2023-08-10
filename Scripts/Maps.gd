@icon("res://Graphics/Collections/PixelLoot/Seperate/tile124.png") 
class_name WorldMap
extends TileMap

var markerPositions:Array[Vector2] = []
@onready var children = get_children()

func _ready():
	#Dynamically save all the marker positions into an array
	for child in children:
		if child is Marker2D:
			if child.name != "P2_Start" and child.name != "P1_Start":
				markerPositions.append(child.global_position)
