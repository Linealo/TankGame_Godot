extends PointLight2D

@onready var startEnergy = energy

func _process(delta):
	var RNGNrStrength = randf_range(-0.15, 0.15)				#Determins flicker strength variations
	
	#Two variables that are random floats
	var RNGNr1 = randi_range(0, 50)						#Determins flicker speed by randomly choosing a delay
	var RNGNr2 = randi_range(0, 50)						#Determins flicker speed by randomly choosing a delay
	#If they match, modulate the energy strength
	if RNGNr1 == RNGNr2:
		energy = startEnergy + RNGNrStrength
