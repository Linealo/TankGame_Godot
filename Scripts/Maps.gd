extends TileMap

var markerPositions:Array[Vector2] = []
@onready var children = get_children()

func _ready():
	#Dynamically save all the marker positions into an array
	for child in children:
		if child is Marker2D:
			markerPositions.append(child.global_position)

