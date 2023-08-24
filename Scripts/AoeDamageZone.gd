extends Area2D

#power will be passed from bullet, but is 1 by default
@export var power:int = 1

func fadeShadow():
	pass

#The area instantly triggers damage on all bodies within that entered them - should only trigger once since `entered` signal
func _on_body_entered(body):
	if body is Tank:
		body.getDamaged(power)
	fadeShadow()

#The explosion animation autostarts. Once it finished, queue_free() the zone
func _on_animated_sprite_2d_animation_finished():
	queue_free()
