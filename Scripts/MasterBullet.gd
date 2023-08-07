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
var canDamage = true
var bounceAmount:int = 1

var canPierce = false
var pierceStorage = null

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
					
	#position += transform.x * delta * shotSpeed						#move the bullet at a set speed by changing its local x position
	if rocketTrailActive:
		handleRocketTrail()

func _physics_process(delta):
	if isAlive:
		velocity = Vector2(1,0).rotated(rotation) * shotSpeed * delta
		collision = move_and_collide(velocity)								#moves the bullet and created a readable flag for the movement and collison, only use the collison though
		#translate(velocity)												#move with translate instead, but use the same vector
		#If there´s a collision reported by move_and_collide and the bullet is not about to be deleted, commence the impact handling
		if collision && not self.is_queued_for_deletion():
			impactHandling()
	else:
		return
	
func reflect():																		#bounces the bullet on hit if bullet can bounce and surface is bouncy
	if bounceAmount >= 1: 															#checks condiditions
		var new_direction = velocity.bounce(collision.get_normal())					#storage for the new direction, that is equal to the colliders normal, using bounce (reflecting a vector)
		rotation = new_direction.angle() #atan2(new_direction.y, new_direction.x)	#Flip the vector of the current rotation by using the arctanges of the new direction vector
		bounceAmount -= 1														
		shotSpeed *= 0.8
		
		#Handle an impact dust on bounce
		var reflectPoof = load("res://Scenes/AnimationHandler.tscn").instantiate()
		add_sibling(reflectPoof)														#Bullet is already instantiated as sibling to the tank on canvas layer, so create sibiling of this again
		reflectPoof.show()
		reflectPoof.set_scale(Vector2(1.5,1.5))
		reflectPoof.position = position
		reflectPoof.rotation = collision.get_normal().angle() + 90								#Set the rotation to the angle of the normal of the collider we´re hitting
		reflectPoof.play("impactDust")
		await reflectPoof.animation_finished											#Wait for the animation to finish and delete the animator node after
		reflectPoof.queue_free()
	
func impactHandling():
	#On impact, check if the grace time has passed and if it did, free all collisions to be active
	if graceTime <= 0:
		for exception in get_collision_exceptions():
			remove_collision_exception_with(exception)
			
	emit_signal('objectHit')
	#update the collider after clearing the collision list to make ithe collider adressable
	collider = collision.get_collider()
	print(collider)
	
	#Player hit detection - always damage tank on hit 
	if collider is Tank and canDamage == true:			#listens to the area body hit, if it has the ability to get damaged and only execute if the one can damage flag is true
		collider.getDamaged(shotPower)									#calls the damage function of the hit body and transmits the shotPower of the current bullet to deal the set amount of damage
	
	#Handle what the bullet does after
	if not canPierce and pierceStorage == null:							#If the bullet can pierce and storage has no value written to it
		if bounceAmount <= 0:											#Explode only if bullet can no longer reflect
			explode(collider)											#calls the explosion function to delete the bullet and show animation / effect based o nwhat it collides with
		else:															#Otherwise bounce the bullet for as often at it can bounce (bounceAmount > 0) 
			#if it´s a bullet or a player, don´t bounce
			if collider is Bullet || collider is Tank: 
				explode(collider)
			#if its anything else, like a wall, bounce
			else:									
				reflect()
	else:																
		#if Bullet can pierce, don´t do anything to it and let it continue
		#the area2D will set the pierceStorage on entering a body or area and thus deactivate the instruction atop
		return
		
	
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

#despawns the object when animation is finished or when the screen is exited
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
func _on_animation_handler_animation_finished():
	queue_free()							



#On entering any type of area or body, if the bullet can pierce store that object for comparison so it can be ingnored and disable collision the collison until exited
func _on_area_2d_body_entered(body):
	print(body, "body")
	if canPierce:
		pierceStorage = body
		$CollisionShape2D.set_deferred("disabled", true)
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
func _on_area_2d_area_entered(area):
	print(area, "area")
	if canPierce:
		pierceStorage = area
		$CollisionShape2D.set_deferred("disabled", true)
		$Area2D/CollisionShape2D.set_deferred("disabled", true)

#On exiting any type of area or body, disable the piercing if the bullet was able to pierce before. Always enable the collision after exiting a body and also clear the storage
#Avoid the trigger all together if the bullet is about to be deleted
func _on_area_2d_body_exited(body):
	if not self.is_queued_for_deletion():
		if canPierce:
			canPierce = false
		pierceStorage = null
		$CollisionShape2D.set_deferred("disabled", false)
		$Area2D/CollisionShape2D.set_deferred("disabled", false)
	else:
		return
func _on_area_2d_area_exited(area):
	if not self.is_queued_for_deletion():
		if canPierce:
			canPierce = false
		pierceStorage = null
		$CollisionShape2D.set_deferred("disabled", false)
		$Area2D/CollisionShape2D.set_deferred("disabled", false)
	else:
		return
