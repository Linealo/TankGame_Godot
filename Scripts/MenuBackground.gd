extends Node2D

var ranNr1: int
var ranNr2: int
@export var ranNrMax: int = 100

var ranProgress: float

@export_category("TankModels")
@export var menuTank: PackedScene

func _process(delta):
	ranNr1 = randf_range(0,ranNrMax)						#Random one for spawning trigger
	ranNr2 = randf_range(0,ranNrMax)						#Random two for spawning trigger
	ranProgress = randf_range(0,1)							#Random number that is used for PathFollow Progress value
	$SpawnPath/PathFollow.set_progress_ratio(ranProgress)
	spawnTank()
	
func spawnTank():
	if ranNr1 == ranNr2:									#Spawn condition
		var t = menuTank.instantiate()						#Create Tank
		add_child(t)										#Add the Tank to the Background node to make it stick below the UI
		t.set_scale(Vector2(0.1, 0.1))						#Set its scale
		t.position = $SpawnPath/PathFollow.position			#Set its spawn position
		t.look_at(get_global_mouse_position())				#Set its spawn rotation 
