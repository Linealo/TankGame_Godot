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

func _process(delta):						#Act function of the engine that is called every frame
	if graceTime > -1:
		graceTime -= 1
		
	#Once the gracTime hits 0 or lower, clear the collision exception list (usually TripleShotBullets)
	if graceTime == 0:
		for exception in get_collision_exceptions():
			if exception != pierceStorage:
				remove_collision_exception_with(exception)
	
	if rocketTrailActive:
		handleRocketTrail()
	
	if canPierce:
		modulate = Color(255,0,0)
	else:
		modulate = Color(0,255,0)
	

func _physics_process(delta):
	if isAlive:
		velocity = Vector2(1,0).rotated(rotation) * shotSpeed * delta
		collision = move_and_collide(velocity)								#moves the bullet and created a readable flag for the movement and collison, only use the collison though
		#translate(velocity)												#move with translate instead, but use the same vector
		
		#If there´s a collision reported by move_and_collide and the bullet is not about to be deleted, commence the impact handling
		if collision and not self.is_queued_for_deletion():
			impactHandling()
		#If theres no collision (collisionShape disabled or nothing being hit) and the storage from piercing is not empty
		if not collision and not pierceStorage == null:
			temporaryCollisionCheck()
	
func impactHandling():
	#check if the grace time has passed and if it did, free all collisions to be active so tripleShots can hit eachother 
#	if graceTime == 0:
#		for exception in get_collision_exceptions():
#			#if get_collision_exceptions() is Bullet:
#			remove_collision_exception_with(exception)		
	emit_signal('objectHit')
	#update the collider after clearing the collision list to make the collider adressable
	collider = collision.get_collider()
	#print(collider)
	print("Bullet pierce ", canPierce)
	#Player hit detection - always damage tanks on hit 
	if collider is Tank:											#listens to the area body hit, if it has the ability to get damaged and only execute if the one can damage flag is true
		collider.getDamaged(shotPower)								#calls the damage function of the hit body and transmits the shotPower of the current bullet to deal the set amount of damage
	
	#Handle what the bullet does after
	if not canPierce:												#If the bullet can´t pierce and storage has no value written to it
		if bounceAmount <= 0:										#Explode only if bullet can no longer reflect
			explode(collider)										#calls the explosion function to delete the bullet and show animation / effect based on what it collides with
		else:														#Otherwise bounce the bullet for as often at it can bounce (bounceAmount > 0) 
			#if it´s a bullet or a player, don´t bounce and still explode instead
			if collider is Bullet || collider is Tank: 
				explode(collider)
			#if its anything else, like a wall, bounce
			else:									
				reflect()
	#if Bullet can pierce, set the piercing to false and disable its collison shape. start the timer for re-enabling the collison shape
	else:																
		pierceStorage = collider #if the piercing was active, save the collider to storage as an exception, so it can´t be hit for sure
		print(pierceStorage)
		add_collision_exception_with(pierceStorage)
		canPierce = false
		if pierceStorage is TileMap:						 						#If the collider is part of the map, disable collision to pierce through walls
			$CollisionShape2D.set_deferred("disabled", true) 
			$WallPierce.start()

func reflect():																		#bounces the bullet on hit if bullet can bounce and surface is bouncy
	if bounceAmount >= 1: 															#checks condiditions
		var new_direction = velocity.bounce(collision.get_normal())					#storage for the new direction, that is equal to the colliders normal, using bounce (reflecting a vector)
		rotation = new_direction.angle() #atan2(new_direction.y, new_direction.x)	#Flip the vector of the current rotation by using the arctanges of the new direction vector
		bounceAmount -= 1														
		shotSpeed *= 0.8
		
		if not collider == pierceStorage:						#clear the pierce storage if the collider is not the wall itself, so it can go throug hit if the wall is the object suppsoed to be pierced
			remove_collision_exception_with(pierceStorage)
		
		#Handle an impact dust on bounce
		var reflectPoof = load("res://Scenes/AnimationHandler.tscn").instantiate()
		add_sibling(reflectPoof)															#Bullet is already instantiated as sibling to the tank on canvas layer, so create sibiling of this again
		reflectPoof.show()
		reflectPoof.set_scale(Vector2(1.5,1.5))
		reflectPoof.position = position
		reflectPoof.rotation = collision.get_normal().angle() + 90							#Set the rotation to the angle of the normal of the collider we´re hitting
		reflectPoof.play("impactDust")
		await reflectPoof.animation_finished												#Wait for the animation to finish and delete the animator node after
		reflectPoof.queue_free()	
	
func explode(collider):													#handles the explosion animation on hit / death of the bullet
	print("Exploded because of ", collider)
	isAlive = false
	$Sprite2D.hide()													#hides the bullet sprite
	$CollisionShape2D.set_deferred("disabled", true)					#disable hitbox to avoid double triggers
	$fireExhaust.hide()													#disable the bullets fire trail
	shotSpeed = 0														#stops the bullet in position so no additional position calculation ahve to take place
	$AnimationHandler.show()											#shows the explosion node
	$AnimationHandler.apply_scale(Vector2(5,5))							#apply a scale (multiply current scale by set amount)
	if not collider.has_method('getDamaged'):							#if the hit collider is not a player (they have the method to take damage)
		$AnimationHandler.apply_scale(Vector2(1.3,1.3))					#play this animation a bit bigger
		$AnimationHandler.play("bulletImpact")							#play a different impact animation animation
	else:																#if it is actually a player
		$AnimationHandler.play("bulletExplosion")						#plays the standard animation

#Collision check for the time when collision is turned off when piercing something
func temporaryCollisionCheck():
	var collisionQuery = PhysicsShapeQueryParameters2D.new()				#Create a collision query without relying on the collision shape
	collisionQuery.shape_rid = $CollisionShape2D.shape.get_rid()			#Make the collision query equal to the collision shape
	collisionQuery.transform.origin = $CollisionShape2D.global_position		#adapt it´s position
	collisionQuery.collide_with_bodies = true								#enable the temporal collision with bodies that is active while the regular collision is inactive
	collisionQuery.collide_with_areas = true								#enable the temporal collision with areas that is active while the regular collision is inactive
	#May add parameters here later, like collision masks
	#Get collision results
	var result = get_world_2d().direct_space_state.intersect_shape(collisionQuery) #Get all shapes that are intersecting the the collisionQuery and save them as results
	#Search the results
	for item in result:														#Go through all the colliders in the result
		if item.collider == pierceStorage:									#If the collider of the result is the same as the one in the originals collisions storage
			return															#return, exiting the check
	#if the return didn´t trigger, reactivate collisions and reset storage
	$CollisionShape2D.set_deferred("disabled", false)						#if the collider was NOT the same as in storage, it means we left the current pierced collider - reactivate normal collision
	remove_collision_exception_with(pierceStorage)							#if the collider was NOT the same as something in storage, it means we left the current pierced collider - remove the exception
	print("Exception removed")
	#canPierce = false
	pierceStorage = null 													#clear the storage
	

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

func _on_wall_pierce_timeout():
	$CollisionShape2D.set_deferred("disabled", false)
#	if pierceStorage == null:
#		$CollisionShape2D.set_deferred("disabled", false)
#	else:
#		$WallPierce.start()
	
