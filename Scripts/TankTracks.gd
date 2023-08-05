extends GPUParticles2D

func _process(delta):
	self.process_material.scale_min = get_parent().scale.x
	self.process_material.scale_max = get_parent().scale.x
