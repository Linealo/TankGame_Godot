extends PointLight2D

func _ready():
	rotation = randi_range(0,360)

func _process(delta):
	rotation += 1 * delta
