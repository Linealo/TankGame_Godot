extends Area2D

#Enum for further use
enum Items 	{					#enumeration list that assigns every PowerUp its own unique integer
			heal,				#0
			invincibility, 		#1
			shield, 			#2
			speedUp, 			#3
			slowDown, 			#4
			freeze, 			#5
			reverse, 			#6
			rocketBullet, 		#7
			wideShot, 			#8
			piercing, 			#9
			tripleShot,			#10
			grenadeBullet, 		#11
			rapidFire,			#12
			bouncyBullet,		#13
			miniMe,				#14
			ultimateWeapon		#15 
			} #(16 Total, starting at 0)

#Variables
@export var type : Items							#Enables the type list from the enum
@export_range(5, 120) var lifetime = 20				#gives a variable to determine the lifetime before the powerup despawns. Must be bigger than 5
@export var overwrite = false						#If Overwrite = true, then the in export set type is used only

#Loads
#Sprite Loads in export
@export_category("Icons")
#Export array of textures. Can be directly linked to the wanted files or afterwards changed in the export variables window
@export var iconTextures: Array[Texture] = [								#preloading some textures that can also be changed in the export variables window
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile301.png"),	#Pos 0: 	heal
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile073.png"),	#Pos 1: 	invicibility
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile069.png"),	#Pos 2: 	shield
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile443.png"),	#Pos 3: 	speedUp
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile447.png"),	#Pos 4: 	slowDown
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile188.png"),	#Pos 5: 	freeze
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile180.png"),	#Pos 6: 	reverse
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile155.png"),	#Pos 7:		rocketBullet
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile110.png"),	#Pos 8: 	wideShot
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile132.png"),	#Pos 9: 	piercing
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile179.png"),	#Pos 10: 	tripleShot
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile166.png"),	#Pos 11: 	grenadeBullet
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile159.png"),	#Pos 12: 	rapidFire
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile498.png"),	#Pos 13: 	bouncyBullets
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile302.png"),	#Pos 14: 	miniMe
	preload("res://Graphics/Collections/PixelLoot/Seperate/tile227.png"),	#Pos 15: 	ultimateWeapon	
	]

#Random Number to generate type
	#create a random number between 0 and 150, devide by 10 and round the result to the closest whole value
	#the range has to be -4 and 154 because the chance for the lowest and highest vlaues are cut in half
	#this is due to rounding. while a value like 13 is achievable with every value from 125 to 134
	#0 is otherwise only achievable from 0 to 4 since at 5 (0.5) it´s being rounded up to 1
	#same for 15, which only starts at 145 eventhough it could until 164 without overflowing into 17 at that point	
@onready var rNr = snapped(randf_range(-5,154)/10, 1)	


#Functions from here
func _ready():												#when created execute the following
	determineType()											#determine the type by using a random number generator
	updateIcon()											#update the Icon according to the found and set up type
	$LifetimeTimer.set_wait_time(lifetime)					#set up the lifetime in the timer
	if $LifetimeTimer.is_stopped() && $LifetimeTimer.get_wait_time() > 0:			#if the timer on startup is stopped for any reason but also has a value that is greater than 0
		$LifetimeTimer.start()								#start it!

func _process(delta):
	if $LifetimeTimer.get_time_left() <= 5 && not $DeathAnimator.is_playing():		#Handle the palying of the death animation (5s long) when the remaining lifetime is lower than 5 seconds
		$DeathAnimator.play("endOfLife")											#play the death animation (will later trigger a signal to queue-free)
	if $LifetimeTimer.get_time_left() == 5:
		$PoofAnimation.show()
		$PoofAnimation.play("impactDust")

func determineType():
	#set the type to the current random number that is created on creation
	#the created random number is equal to
	if not overwrite:
		type = rNr

#function to update the icon to the corresponding type of the powerup
func updateIcon():
	#Set the IconSprite texture to the texture that is linked to the enum position within the IconTexture array
	$Sprite2DIcon.texture = iconTextures[type]
	
func _on_PowerUp_body_entered(body):			#Signal that gets triggered on touch
	$DeathAnimator.stop()						#Stop Death Animation and any connected method calls if the powerUp is collected, preventing it from queue_free()
	$Descriptor.show()
	match type:									#switchcase
		#If type == heal, then heal player by a value of 1
		Items.heal:
			$Descriptor.text = "Health Up!"
			if body.has_method("heal"):
				body.heal(1)	
		#If type == invincibility, then toggle flag to make player invincible
		Items.invincibility:
			$Descriptor.text = "Invincible for 5s!"
			body.invincible = true
			body.get_node("InvincibilityTimer").start()
		#If type = shield, then toggle flag to signal the shield being up and add 1 HP to the shield
		Items.shield:
			$Descriptor.text = "Shield +1!"
			body.shieldUp = true
			body.shieldHP += 1
		#If type == speedUp, then toggle flag within the tank that increases the speed and start the timer for the buff to wear out
		Items.speedUp:
			$Descriptor.text = "Speed Up!"
			body.speedUp = true
			body.get_node("SpeedUpTimer").start()
		#If type == slowDown, then toggle flag within the other tanks that lowers the speed and starts the timer for the nerf to wear out
		Items.slowDown:
			$Descriptor.text = "Enemy slow down!"
			if body.name == "Tank_P1":
				body.get_parent().get_node("Tank_P2").slowDown = true
				body.get_parent().get_node("Tank_P2/SlowDownTimer").start()
			if body.name == "Tank_P2":
				body.get_parent().get_node("Tank_P1").slowDown = true
				body.get_parent().get_node("Tank_P1/SlowDownTimer").start()
		Items.freeze:
			$Descriptor.text = "Enemy freeze!"
			if body.name == "Tank_P1":
				body.get_parent().get_node("Tank_P2").isFrozen = true
				body.get_parent().get_node("Tank_P2/FreezeTimer").start()
			if body.name == "Tank_P2":
				body.get_parent().get_node("Tank_P1").isFrozen = true
				body.get_parent().get_node("Tank_P1/FreezeTimer").start()
		Items.reverse:
			$Descriptor.text = "Enemies controls reversed!"
			if body.name == "Tank_P1":
				body.get_parent().get_node("Tank_P2").controlsReversed = true
				body.get_parent().get_node("Tank_P2").rotationSpeed *= -1
				body.get_parent().get_node("Tank_P2/ReverseTimer").start()
			if body.name == "Tank_P2":
				body.get_parent().get_node("Tank_P1").controlsReversed = true
				body.get_parent().get_node("Tank_P1").rotationSpeed *= -1
				body.get_parent().get_node("Tank_P1/ReverseTimer").start()
		#If type == rocketBullet, then give +1 Rocket Bullet to the player, that then is consumed on the next shot
		Items.rocketBullet:
			$Descriptor.text = "Rocket Bullet +1"
			body.shootRocket += 1
		#If type == wideBullet, then give +1 Wide Bullet to the player, that then is consumed on the next shot
		Items.wideShot:
			$Descriptor.text = "Wide Bullet +1"
			body.shootWide += 1
		#If type == piercing, then give +1 piercing to the player, that then is consumed on the next shot
		Items.piercing:
			$Descriptor.text = "Piercing Bullet +1!"
			body.shootPiercing += 1
		#If type == tripleShot, then give +1 triple Shot, that then is consumed on the next shot
		Items.tripleShot:
			$Descriptor.text = "Triple Shot +1"
			body.shootTriple += 1
		#If type == grenadeBullet, then give +1 grenadeBUllet, that then is consumed on the next shot
		Items.grenadeBullet:
			$Descriptor.text = "Grenade Bullet +1"
			body.shootGrenade += 1
		#If type == rapidFire, then toggle a flag within the tank, that lowers the show delay timer, allowing it to fire faster / with shorter intervals
		Items.rapidFire:
			$Descriptor.text = "Rapid Fire Shooting!"
			body.rapidFire = true		
			#Set new value to the shot delay in the tank that colelcted the powerup
			body.get_node("ShotTimer").set_wait_time(0.5) 
			#start the timer that will reset the delay to the old value after a given time
			body.get_node("RapidFireTimer").start()
		#If type == bouncyBullet, then add + 1 bouncyBullet to the player
		Items.bouncyBullet:
			$Descriptor.text = "+3 Bounces"
			body.shootBouncy += 1
		#If type == miniMe, then shrink the player, to make them harder to hit. Start a reset timer for it
		Items.miniMe:
			$Descriptor.text = "Shrink Shroom!"
			if not body.isMini:						#Only scale down the player if they´re not already small (PowerUp cannot stack)
				body.apply_scale(Vector2(0.5,0.5))
				body.isMini = true
			body.get_node("MiniTimer").start()		#Outside the flag check, so the timer get´s refreshed even if already mini
		#If type = ultimateWeapon, then set start the timer
		#The player will set movementspeed to 0 (only rotation), make itself invincible, give low cooldown on shooting, but make bullets slow
		Items.ultimateWeapon:
			$Descriptor.text = "THE ULITMATE WEAPON"
			body.ultiMode = true
			body.get_node("ShotTimer").set_wait_time(0.25)
			body.get_node("UltiTimer").start()
	playEffects()

func playEffects():									#standartised effect order for this powerup
	$Sprite2DIcon.hide()							#disable Sprite on collection
	$Sprite2DShadow.hide()							#hide the shadow aswell
	$CollisionShape2D.queue_free()					#delete the hitbox so it can´t be picked up twice
	#Trigger two animations and sound
	poofAnimation()
	pickUpAnimation()
	infoAnimation()
	$PickUpSound.play()								#play pickup sound

func poofAnimation():
	$PoofAnimation.set_scale(Vector2(0.6,0.6))		#set poof cloud size
	$PoofAnimation.show()							#show poof cloud node
	$PoofAnimation.play("impactDust")				#play poof cloud animation

func pickUpAnimation():
	$PickUpAnimation.set_scale(Vector2(0.6,0.6))	#set effect node size
	$PickUpAnimation.position.y -= 10  				#correct effect node position
	$PickUpAnimation.show()							#enable the animation handler
	$PickUpAnimation.play("powerUpPickUp")			#play pickup animation

func infoAnimation():
	$Descriptor/AnimationPlayer.play("RiseAndFade")

#Conditional Queue_Free of the PowerUp based on if animation or sound finish last (likned to two signals)
func _on_pick_up_animation_finished():				#remove powerUp after pickup animation finishes
	if not $PickUpSound.is_playing():				#but not before the soudn has finished
		queue_free()
func _on_pick_up_sound_finished():					#remove powerup after sound has finished
	if not $PickUpAnimation.is_playing():			#but not before the animation has finished
		queue_free()

#Alternative Queue_Free that triggers if the death animation finishes
func _on_death_animator_animation_finished():									#at death animation finish
	$CollisionShape2D.queue_free()												#always disable hitbox
	$Sprite2DIcon.queue_free()													#always delete the Sprite
	$Sprite2DShadow.queue_free()												#and its icons
	poofAnimation()
	if not $PickUpAnimation.is_playing() && not $PickUpSound.is_playing():		#don´t queue_free the whole node if an animation or sound is still playing
		queue_free()															#if none is playing, queue free, otherwise those will queue free on them finishing
