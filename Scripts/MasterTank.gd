@icon("res://Graphics/models/Tank5.png") 
class_name Tank
#Importing internal class features from Godot
#extends Area2D
extends CharacterBody2D

#Setting events that can be read by other classes and the engine
signal tankShoots						#Reports a signal to the engine that the player called the shoot function
signal healthChange						#Reports to the enginge if the health changes
signal playerDied						#Reports to the engine the current state of being alive. Easier said: Reports to the game once the player dies
signal shieldBreak

#Exporting values so those can be accessed outside (equivalent to public variable)
#Exporting Bullet Scene so every tank can be assigned own bullets easily
@export_category("Scenes")
@export var bullet: PackedScene			#Allow to export a scene, here a bullet, to allow different bullets for different tanks

#Export important values that can be set per tank easily
@export_category("Stats")
@export var moveSpeed:float	= 200		#Export the movespeed to be accessible i.e. by PowerUps
@export var rotationSpeed:float			#Export the rotationspeed to be accessible i.e. by PowerUps
@export var shotDelay:float				#Export the shotdelay to be accessible i.e. by PowerUps
@export var startHealth:int				#Export the health value to allow the game to set a starting health on spawn
@export var dashDelay:float				#Export the current dashDelay to be accessible i.e. by PowerUps and instances
@export var bulletDamage:int = 1		#Export the damage this tanks bullets will do
@export var bulletSpeed:int = 800

#Export control scheme so tank controls don´t need to be double in the tank scripts themselves. Replace "x" with withe players number
@export_category("ControlKeys")
@export var fwKey = "Px_Forward"
@export var bwKey = "Px_Backward"
@export var rtlKey = "Px_RotateLeft"
@export var rtrKey = "Px_RotateRight"
@export var shootKey = "Px_Shoot"
@export var dashKey = "Px_Dash"

#Variables for tank state
var isAlive = true						#Is held "true" while the HP of the tank is greater than 0. 
var currentHealth	= startHealth		#Initiate the health value of the tank and set it to the configured startingHealth when loading up the game
var canShoot = true						#variable that gets set to true once the timer from $ShotTimer withing the class reaches 0 
var canDash = true
var isDashing = false
var cantBeHurt = false					#variable that makes player invurnable after being hit - separate from invincibility through powerUps

#Movement variables
var currentSpeed = 0			#variabel to store the current movement speed
var maxSpeed 					#Cap maximum positive speed at value defined in creation
var maxNegSpeed 				#Cap maximum negative speed at 2/3rds of maximum forwards speed
var acceleration 				#Acceleration is equal to 10% of the maximum speed
var friction					#Decaleration is equal to 5% of the maximum speed

#PowerUp checks
#Bullet PowerUps --> Number determines how often it can be shot. Multiple powerups can increase amount of uses
var shootRocket = 0
var shootWide = 0
var shootPiercing = 0
var shootTriple = 0
var shootGrenade = 0
var shootBouncy = 0
#Modifications
var speedUp = false
var slowDown = false
var isFrozen = false
var controlsReversed = false
var rapidFire = false
#Others
var invincible = false
var shieldUp = false
var shieldHP = 0
var isMini = false
var ultiMode = false

var currentHue:float = 0

func _ready():									#Constructor 
	#pre-load resources
	
	#Initialise the tank
	cantBeHurt = false
	currentHealth = startHealth								#doubling up the initilastion so the tank is surely spawned with the max health upon creation (ready state)
	emit_signal('healthChange', currentHealth) 	#update the signal with the current health grabbed from the initilisation to make 100% sure the healthBar is showing correctly
	
	#Initialiste the movement variables
	maxSpeed = moveSpeed									#Cap maximum positive speed at value defined in creation
	maxNegSpeed = moveSpeed * -1 * 0.66						#Cap maximum negative speed at 2/3rds of maximum forwards speed
	acceleration = moveSpeed * 1							#Acceleration is equal to 10% of the maximum speed
	friction = moveSpeed * 3								#Decaleration is equal to 5% of the maximum speed
	
	#load the ShotTimer with the allocated delay
	$ShotTimer.wait_time = shotDelay			#Set the class`s configured timers (ShotTimer) wait time value to the object initiated shotDelay so the guy can´t fire before the delay reaches 0. Allows to set "CanShoot" to true if 0

func _process(delta):
	handleTankTracks()
	
	#Refresh speed parameters every frame to get consistent appliance of them
	maxSpeed = moveSpeed
	maxNegSpeed = moveSpeed * -1 * 0.66
	acceleration = moveSpeed * 1
	friction = moveSpeed * 3
	
	#Enable and disable the shield graphcis depending on if the shield is active or not
	if shieldUp:
		$Shield.show()
	elif not shieldUp:
		$Shield.hide()
		
	#Control invurnability visual effect through shader / 0-1 being a full rotation in hue
	if invincible:
		currentHue += randf_range(0.0001, 0.01)   #number here controls hue rotation speed randomized for making it look less linear
		if currentHue == 1:
			currentHue = 0
	elif not invincible:
		currentHue = 0
	$Body.material.set_shader_parameter("Shift_Hue", currentHue)
	
#Physics Process processes the games physics, i.e. movement, every frame
func _physics_process(delta): 			#NOTE: Detla =>  time elapsed during a frame, used to control the display of movement based on frame time. IE 120 Pixel/sec movement with a delta of 60FPS (1/60), makes the player move 2px every frame or 120pixels every second
	if not isAlive:						#if not alive, skip this function and thus don´t call the movement and action functions
		return
	control(delta)						#if alive, call the control function
	move_and_collide(velocity)			#move configuration with collision from the characterbody2D class

#Everything movement from here
func control(delta):								#Control function that is called every frame. Controls are configured based on player in their own script, overwriting this class functions content
	#$Canon.look_at(get_global_mouse_position())	#Makes the Canon of the player follow the mouse cursor at all times. Disabled because we have a fixed Canon
	#var rotationDirection = 0						#Temporary variable that only exists at the call of the function to determine the rotation direction of the player object
	
	#REFURBED BASE MOVEMENT: Smooth motion with acceleration and decalteration
	speedRamp(delta)
		
	#Key registration for movement. Keys and Keyhortcuts are registered in ProjectSettings window inside the engine
	#Rotation of player
	#Rotate the player on key press. Rotate at 2/3rds of speed when driving backwards at the same time
	rotatePlayer(delta)

	#Shoot Bullet
	if Input.is_action_just_pressed(shootKey):						#Register shooting key set in project settings
		shoot()
	#Dash
	if Input.is_action_just_pressed(dashKey) && $DashTimer.is_stopped():
		#dash(delta)
		$DashTimer.start()
	
func rotatePlayer(delta):
	if Input.is_action_pressed(rtrKey):
		if Input.is_action_pressed(bwKey):
			rotate(rotationSpeed * 1 * delta * 0.66)				#Rotate the player if they´re NOT moving foward by the regular rotation speed given in the object
		elif Input.is_action_pressed(fwKey):
			rotate(rotationSpeed * 1 * delta * 1)
		else:
			rotate(rotationSpeed * 1 * delta * 0.5)					#Rotate the player a lowwer speed speed if they´re going backwards at the same time
	if Input.is_action_pressed(rtlKey):								#GD Script variant of "else if" = elif. Avoids hitting both rotations at the same time
		if Input.is_action_pressed(bwKey):
			rotate(rotationSpeed * -1 * delta * 0.66)				#Rotate the player if they´re NOT moving foward by the regular rotation speed given in the object. Negative for left turn
		elif Input.is_action_pressed(fwKey):
			rotate(rotationSpeed * -1 * delta * 1)
		else:
			rotate(rotationSpeed * -1 * delta * 0.5)				#Rotate the player at a lower speed speed if they´re going backwards at the same time. Negative for left turn
			
#Smooth speed ramping and friction breaking
func speedRamp(delta):
	#Accelerating positive (forward acceleration)
	if Input.is_action_pressed(fwKey) && currentSpeed <= maxSpeed:							#When moving forward and speed is not over maxSpeed
		currentSpeed += acceleration * delta												#add accerlation value for that frame (10% of maxSpeed)
		
	#accelerating negative (backwards acceleration)
	if Input.is_action_pressed(bwKey) && currentSpeed >= maxNegSpeed:						#When moving backwards and negative speed is not lower than maximum negative speed
		currentSpeed -= acceleration * delta											#Keep increasing negative speed (faster backwards driving)
			
	#friction breaking when no key is pressed
	if not Input.is_action_pressed(fwKey) && not Input.is_action_pressed(bwKey):
		if currentSpeed > 0:																#If the speed is greater than 0 but no move is triggered			
			currentSpeed -= friction * delta												#use the friction value to lower the current speed until 0
			if currentSpeed < 0:															#if this makes the current Speed fall below 0
				currentSpeed = 0															#set the speed to 0 to avoid acidental backwards movement when breaking
		elif currentSpeed < 0:																#If the speed is lower than 0 and no move is triggered
			currentSpeed += friction * delta												#use the friction to negate the negative speed and thus breake backwards
			if currentSpeed > 0:																#if the current speed jumps over 0 during this negative breaking
				currentSpeed = 0															#set the speed to 0 to avoid moving forward when breaking from going backwards
	
	#Speed Blockade / Limit
	if currentSpeed > maxSpeed:
		currentSpeed = maxSpeed																#When current speed exdeeds max Speed, set to maxSpeed
	if currentSpeed < maxNegSpeed:
		currentSpeed = maxNegSpeed															#When current speed is lower than max negative Speed, set to maxNegSpeed
		
	#Execute Movement
	movePlayer(currentSpeed, delta)

#actual moving function that determines the position by taking the created velocity, frametimes and current movespeed into account
func movePlayer(totalMoveSpeed, delta):
	#SpeedOverwrites from PowerUps, allowing to exceed limits
	#Conditions from PowerUpEffects. Can easily change total movement speed during exectuting, circumventing the limitations of MaxSpeed because they´re not checked here anymore
	if speedUp:
		totalMoveSpeed *= 1.5					#move 50% faster when sped UP
	if slowDown:
		totalMoveSpeed /= 2					#move 50% slower when slowed Down
	if isMini:
		totalMoveSpeed *= 1.5					#Let the player move a bit faster to compensate for being smaller
	if isFrozen:
		totalMoveSpeed = 0
	if controlsReversed:
		totalMoveSpeed *= -1
		
	#Ultimate Weapon mode at the end, because it overwrites everything
	if ultiMode:
		totalMoveSpeed = 0
	
	#old movement based on position transform
	#position += transform.x * currentMoveSpeed * delta						
	#new movement that is based on the internal velocity calculations. MUCH MORE SENSITIVE TO SPEED CHANGE! 
	velocity = Vector2(1,0).rotated(rotation) * totalMoveSpeed * delta
	
func shoot():									#Shooting function for all tanks
	if not canShoot:							#if "canShoot" is false, skip the whole shooting thingy
		return
	elif canShoot:								#if can shoot is true, then allow for shooting
		#play sound for shooting
		$Sound_BulletKlink.play()
		$Sound_BulletShot.play()
		canShoot = false						#if canShoot was true, set canShoot to false now to avoid another shot
		$ShotTimer.start()						#start the shot delay timer to count down towards 0, where it will reset later
		#play animation at muzzle location
		$MuzzleFire.show()
		$MuzzleFire.position = $Canon/BulletSpawnPoint.position
		$MuzzleFire.set_scale(Vector2(1.3,1.3))
		#$AnimationHandler.rotation = $Canon.global_rotation
		$MuzzleFire.play("muzzleFire")
		
		#Create the actual bullet
		if shootTriple:
			var TSbullets:Array = []  #Create an array only for this shot that stores all bullets shot at the same time
			shootTriple -= 1
			#Add 2 to every applicable modifier, so that all 3 bullets will have all thier bullets modified if an applicable modifier is active
			if shootRocket > 0:
				shootRocket += 2
			if shootWide > 0:
				shootWide += 2
			if shootPiercing > 0:
				shootPiercing += 2
			if shootGrenade > 0:
				shootGrenade += 2
			#Spawn 3 Bullets and spread them by a rotation value
			for angle in [-0.1, 0, 0.1]:
				var b = createBullet()
				print("TripleShot created")
				b.rotate(angle)
				b.graceTime = 35													#Force a GraceTime so the bullets don´t collide on spawn
				modifyBullets(b)													#modify the bullets
				get_parent().add_child(b)											#create the bullet as a new child and thus place it in the world, ready to act
				TSbullets.append(b)													#Add shot bulelt to the TrippleShot bullet array
			for i in TSbullets.size():												
				for j in TSbullets.size():
					if i != j and is_instance_valid(TSbullets[i]) and is_instance_valid(TSbullets[j]):
						TSbullets[i].add_collision_exception_with(TSbullets[j])		#make collison exception for the bulelts in the array
		else:
			var b = createBullet()
			modifyBullets(b)														#modify the bullets 
			get_parent().add_child(b)												#create the bullet as a new child and thus place it in the world, ready to act
	else:
		return

#Creating the bullet instance to be added to a scene
func createBullet():
	var b = bullet.instantiate()											#load the bullet that has been selected at that scene via the export of the packed scene a top of this code
	b.transform = $Canon/BulletSpawnPoint.global_transform 					#Set bullet transform postiion and rotation to the canons bullet spawn point rotation of that tank
	b.shotPower = bulletDamage												#Set the bullets power level to this tanks bullet damage for this shot. Can be affected by other powerUps
	
	return b

#Modifiers from the powerUps
func modifyBullets(b):
	#If the player is small, scale up the bullets back to normal
	b.shotSpeed = bulletSpeed
	
	if isMini:
		b.apply_scale(Vector2(2,2))
		#b.shotSpeed *= 1.5
	
	#Add bounces to the bullet
	if shootBouncy > 0:
		b.bounceAmount = 3
		shootBouncy -= 1	
			
	if shootRocket > 0:														#Can be used if the "ammo" for it is higher than 0
		b.get_node("Sprite2D").apply_scale(Vector2(1.3,1.3))				#Adjust scale
		b.get_node("CollisionShape2D").apply_scale(Vector2(1.3, 1.3))		
		b.shotSpeed *= 2													#rocket Bullets are twice as fast
		b.rocketTrailActive = true											#add fire effect animation behind the bullet
		b.bounceAmount = 0													#Rocket Bullets can´t bounce - thus after "shootBouncy"
		shootRocket -= 1													#deduct one use of this powerUp
		
	if shootWide > 0:														#Can be used if the "ammo" for it is higher than 0
		#maybe later refer to a different sprite / bullet over all instead of scaling 
		b.graceTime = 250
		b.position += Vector2(50,0).rotated(rotation)						#move a bit forward to avoid hitting the player on spawn
		b.get_node("Sprite2D").apply_scale(Vector2(1,15))					#scale the shot to wide (Bullet & collision box of the bullet). By applying a scale isntead of setting one it can modify other modifiers from before
		b.get_node("CollisionShape2D").apply_scale(Vector2(1,15))			
		b.shotSpeed *= 0.7													#wideShot comes with a penalty in speed for being wide
		b.get_node("fireExhaust").apply_scale(Vector2(1.3,7))
		b.get_node("fireExhaust").position += Vector2(-100,-370)
		shootWide -= 1 # remove one use of the powerUp
		
	if shootPiercing > 0:
		b.canPierce = true
		shootPiercing -= 1
		
	if shootGrenade > 0:
		b.AoeDamage = true
		shootGrenade -= 1
		
	#Ultimode uses rocketbullets
	if ultiMode:
		b.shotSpeed *= 1.5
		b.rocketTrailActive = true
		b.bounceAmount = 0
	
	#If the tank has no light on, disable it for the bullet as well
	#NOTE: 
	#DungeonLight is a light used on the dungeon map to cast shadows around corners
	#GeneralLight is a light withou shadow properties to illuminate the surrounding regardless of occlusion shapes
	if $DungeonLight.is_visible():
		b.get_node("DungeonLight").show()
	if $GeneralLight.is_visible():
		b.get_node("GeneralLight").show()
	
	#Return the bullet with all it´s added features
	return b

#Function to make the player dash	
#func dash(delta):
#	canDash = false
#	$DashTimer.start()
#	position += transform.x * moveSpeed * delta

#Handle when the tank draws tracks with its particle emitter
func handleTankTracks():	
	#If the tank is moving or rotate inputs are being made, activate the emission of particles to be left behind
	if velocity != Vector2(0,0) or Input.is_action_pressed(rtrKey) or Input.is_action_pressed(rtlKey):
		if $TankTracks.emitting == false:
			#print("TankTracks enabled")
			$TankTracks.emitting = true
	elif velocity == Vector2(0,0):
		if $TankTracks.emitting == true:
			#print("TankTracks disabled")
			$TankTracks.emitting = false

#Damage handling
func heal(amount):																#healing function
	if currentHealth < startHealth:												#if current health is not greater or equal to maximum health
		currentHealth += amount													#add the amount of health that is parsed when the function is called
		emit_signal("healthChange", currentHealth)								#emmit a signal with the current health to update the health bar

func getDamaged(amount):														#Function to take damage. Will be checked and called on bullet impact (see MasterBullet _on_area_entered function)
	print("Player was hit by bullet")
	#play sound for being hit
	$Sound_Hurt.play()
	#Prioritise the shield getting damaged before the player, even if invurnable
	if shieldHP > 0:
		print("but had a shield")
		var damageOverflow:int = 0
		if shieldHP < amount:							#If there´s more damage incoming than the shield can take, calulate the difference and execute the damage function agai with the rest value as overflow
			damageOverflow = amount - shieldHP
		shieldHP -= amount								#Make the shield take damage according to the bullets value
		if shieldHP < 1:								#If the shield is destroyed, set the shieled flag to false and shield HP to 0 (could be negative)
			shieldUp = false
			shieldHP = 0	
			emit_signal("shieldBreak")
		if damageOverflow > 0:
			getDamaged(damageOverflow)						#recursive call to apply Overflow damage
	elif invincible || ultiMode || cantBeHurt:			#if player is invincible of any kind, quit the current function execution
		print("but is invincible")
		return
	else: 												#if there´s no shield (ShieldHP <= 0) and the priot invicibility check is false, handle damage 
		print("and took damage")
		currentHealth -= amount							#update the current health based on the amount of damage applied. amount is determined by bullet power
		emit_signal('healthChange', currentHealth)		#trigger the signal to update the healthbar and send with it the current health value
		cantBeHurt = true
		$HurtTimer.start()								#Start the hurt timer, that will reset the cenBeHurt state, so there´s a delay after being hit before player can take damage again
		if currentHealth <= 0:							#check for death condition
			print("and died")
			die()

func die():
	isAlive = false
	$Body.hide()									#hides the body sprite
	$Canon.hide()									#hides the canon sprite
	$StatusBar.hide()								#hide the status bar
	$CollisionShape2D.queue_free()					#disables the players collision detection
	#Moved Signal Trigger for death to after the animation finished, so the animation doesn´t get cut off before it can finish
	explode()

func explode():										#explode function to kill the tank
	#play Death sound
	if not $Sound_Death.is_playing():
		$Sound_Death.play()
	
	$AnimationHandler.show()						#shows the explosion node
	$AnimationHandler.apply_scale(Vector2(5,5))		#scale the death animation
	$AnimationHandler.global_position.y -= 75		#correct the position relative to the tanks center
	$AnimationHandler.global_rotation = 0			#force the rotation of the animation to be upwards
	$AnimationHandler.play("tankExplosion")			#plays the fireExplosion animation from the animatedSprite node

#Death handling. Two function that trigger on signals to despawn the object to free up memory. Both sound and animation need to be played. If one or the other hasn´t finished yet, it waits for the other one to finish first before despawning so that they get fully played.
func _on_animation_handler_animation_finished():			#when animation signals that it has finished
	$AnimationHandler.hide()								#always hide the explosion once the animation is finished
	if not $Sound_Death.is_playing(): 						#let the death sound play out if it takes longer than the animation
		await get_tree().create_timer(0.3).timeout
		emit_signal("playerDied")							#trigger death signal after animation finish, so animation ins´t paused with rest of game on death
		queue_free()										#despawn the object
func _on_sound_death_finished():							#Once the death sound finished, clear the object
	if not $AnimationHandler.is_playing():					#if the animation is still playing, don´t despawn the obejct
		await get_tree().create_timer(0.3).timeout
		emit_signal("playerDied")							#trigger death signal
		queue_free()										#despawn the object

func _on_hurt_timer_timeout():
	cantBeHurt = false

#DEPRECATED - Healthbar moved to HUD control scheme		
func _on_health_change(value):								#signal gets triggered on health change
	$StatusBar.healthBarUpdate(value)						#to update the status bar ontop of the player (old version - is hidden)

func _on_player_died():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	get_parent().get_parent().get_node("GameOver").show()
	get_parent().get_parent().get_node("GameOver/GameOverOverlay/VBoxContainer/Restart").grab_focus()

#Timer Timeouts: When the given timer stops,the code inside their respective function will be executed immideatly and automatically
func _on_shot_timer_timeout():
	canShoot = true
	
func _on_dash_timer_timeout():
	canDash = true
	
func _on_invincibility_timer_timeout():
	invincible = false
	#print("invincibility deactivated")
	
func _on_speed_up_timer_timeout():
	speedUp = false
	
func _on_slow_down_timer_timeout():
	slowDown = false
	
func _on_freeze_timer_timeout():
	isFrozen = false

func _on_reverse_timer_timeout():
	controlsReversed = false
	rotationSpeed *= -1				#reset rotiation speed
		
func _on_rapid_fire_timer_timeout():
	#Resets the buff when the powerUp wears off
	if not ultiMode:
		$ShotTimer.set_wait_time(2)
	rapidFire = false
	
func _on_mini_timer_timeout():
	isMini = false
	#Rescale the player
	self.apply_scale(Vector2(2,2))

func _on_ulti_timer_timeout():
	if not rapidFire:
		$ShotTimer.set_wait_time(2)
	ultiMode = false
