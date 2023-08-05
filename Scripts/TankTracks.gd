extends GPUParticles2D

func _process(delta):
	#Set the particle scale to the parents scale, so the tracks match the tanks size
	#make sure to talk to the ressource and make the ressource local to scene so it doesn´t affect other systems using the same ressource
	self.process_material.scale_min = get_parent().scale.x
	self.process_material.scale_max = get_parent().scale.x
