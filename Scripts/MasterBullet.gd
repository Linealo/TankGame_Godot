@icon("res://Graphics/UI/SimpleKeys/Classic/Dark/Single PNGs/BACKSPACE.png" )
class_name Bullet
#extends Area2D								#Remenant of being an Area2D Node
extends CharacterBody2D

signal pesistanceOver						#Signal for when the persistance is over
signal objectHit							#Signal for when the obejct has hit something

var collision
var collider

@export var trailScene : PackedScene		#export a slot where the little fire animation on the back of the bullet can be added into
@export var rocketTrailScene: PackedScene	#export a slot for where the rocket bullet animation goes

@export var shotSpeed:float = 800			#Export the speed value
@export var shotPower:int = 1				#Export the damage the bullet does in a set value to hurt objects that can receive damage
@export var persistanceTime:float			#Export time the bullet still persists on the map

var isAlive = true							#variable to check if the bullet is persistant or not
var bounceAmount:int = 1
var canPierce = false

var rocketTrailActive = false

var hits:Array = []							#Storage for hit objects

#Time the bullet has no hit detection on other bullets / Area type objects after spawn
@export var graceTime = 0	#GraceTimer for TripleShot

func _ready():
	pass

func _process(delta):													#Act function of the engine that is called every frame
	if graceTime > 0:
		graceTime -= 1
	#Once the gracTime hits 0 or lower, clear the collision exception list (usually TripleShotBullets)
	if graceTime <= 0:
		for exception in get_collision_exceptions():
			remove_collision_exception_with(exception)
					
	#position += transform.x * delta * shotSpeed						#move the bullet at a set speed by changing its local x position
	if rocketTrailActive:
		handleRocketTrail()

func _physics_process(delta):
	velocity = Vector2(1,0).rotated(rotation) * shotSpeed * delta
	collision = move_and_collide(velocity)								#moves the bullet and created a readable flag for the movement and collison, only use the collison though
	#translate(velocity)												#move with translate instead, but use the same vector
	if collision && not self.is_queued_for_deletion():
		impactHandling()
	
func reflect():															#bounces the bullet on hit if bullet can bounce and surface is bouncy
	if bounceAmount >= 1: 												#checks condiditions
		var new_direction = velocity.bounce(collision.get_normal())
		rotation = atan2(new_direction.y, new_direction.x)
		bounceAmount -= 1
		shotSpeed *= 0.8
	
func impactHandling():
	emit_signal('objectHit')
	collider = collision.get_collider()
	#Player hit detection
	if collider is Tank && collider.has_method("getDamaged"):			#listens to the area body hit, if it has the ability to get damaged
		collider.getDamaged(shotPower)									#calls the damage function of the hit body and transmits the shotPower of the current bullet to deal the set amount of damage
	#Handle what the bullet does after
	if not canPierce:													#If the bullet can pierce, don´t destroy it
		if bounceAmount <= 0:											#Explode only if bullet can no longer reflect
			explode(collider)											#calls the explosion function to delete the bullet and show animation / effect based o nwhat it collides with
		else:															#Otherwise bounce the bullet for as often at it can bounce (bounceAmount > 0) 
			#if it´s a bullet or a player, don´t bounce
			if collider is Bullet || collider is Tank: 
				explode(collider)
			#if its anything else, like a wall, bounce
			else:									
				reflect()
	else:																#if Bullet can pierce, don´t do anything to it and let it continue, but set the pierce to off
		canPierce = false												#Disable piercing after piercing once										
		#Somehow ignore the current collider until projectile no longer collides with it
		
	
func explode(collider):													#handles the explosion animation on hit / death of the bullet
	print("Exploded because of", collider)
	isAlive = false
	$Sprite2D.hide()													#hides the bullet sprite
	$CollisionShape2D.queue_free()										#disable hitbox to avoid double triggers
	$fireExhaust.hide()													#disable the bullets fire trail
	shotSpeed = 0														#stops the bullet in position so no additional position calculation ahve to take place
	$AnimationHandler.show()											#shows the explosion node
	$AnimationHandler.apply_scale(Vector2(5,5))							#apply a scale (multiply current scale by set amount)
	if not collider.has_method('getDamaged'):							#if the hit collider is not a player (they have the method to take damage)
		$AnimationHandler.apply_scale(Vector2(1.3,1.3))					#play this animation a bit bigger
		$AnimationHandler.play("bulletImpact")							#play a different impact animation animation
	else:																#if it is actually a player
		$AnimationHandler.play("bulletExplosion")						#plays the standard animation

func handleRocketTrail():
	var trail = rocketTrailScene.instantiate() as GPUParticles2D
	get_parent().add_child(trail)
	trail.rotation = $Sprite2D.global_rotation
	trail.position = $Sprite2D.global_position

func _on_PersistanceTimer_timeout():		#deletes the bullet once its lifetime persistance timer runs out by listening for internal timer timeout signal
	#queue_free()
	pass

#Remenants of using Area2D
#func _on_area_entered(area):				#check if the bullet entered another object of the type area2D (need this because bullet might hit objects that are area2d objects)
#	if graceTime <= 0:
#		impactHandling(area)
#
#func _on_body_entered(body):				#check collision for area2s bullet on a characterbody2d type object (Need this because player is c-body2d object) 
#	impactHandling(body)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_animation_handler_animation_finished():
	queue_free()							#despawns the object when animation is finished



