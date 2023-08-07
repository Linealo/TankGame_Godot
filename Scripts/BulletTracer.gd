extends Line2D

func _process(delta):
	points[0] = get_parent().position
	points[1] = get_parent().target_position
