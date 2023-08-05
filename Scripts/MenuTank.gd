extends CharacterBody2D

@export var tankTexture: Array[Texture] = [								#preloading some textures that can also be changed in the export variables window
	preload("res://Graphics/models/Tank1.png"),	#Pos 0:
	preload("res://Graphics/models/Tank2.png"),	#Pos 1:
	preload("res://Graphics/models/Tank3.png"),	#Pos 2:
	preload("res://Graphics/models/Tank4.png"),	#Pos 3:
	preload("res://Graphics/models/Tank5.png"),	#Pos 4:
	]

var onScreen = false		#On-Screen Flag
var rngTex: int				#Creates a random number for texture array to load

func _ready():
	#When tank is spawned, decide a texture based on a random number calling textures from an Array
	rngTex = randf_range(-1,5)
	print(rngTex)
	$Body.texture = tankTexture[rngTex]

func _physics_process(delta):
	move(delta)
	move_and_collide(velocity)
	
func move(delta):
	velocity = Vector2(1,0).rotated(rotation) * 150 * delta

func _on_menu_death_timer_timeout():		#Death timer for the menu tank, so it unloads after a while
	explode()
	
func explode():										#explode function to kill the tank
	set_physics_process(false)
	$Body.hide()									#hides the body sprite
	$Canon.hide()									#hides the canon sprite
	$StatusBar.hide()								#hide the status bar
	$CollisionShape2D.queue_free()					#disables the players collision detection
	
	if onScreen:
		if not $Sound_Death.is_playing():
			$Sound_Death.play()
		$AnimationHandler.show()						#shows the explosion node
		$AnimationHandler.apply_scale(Vector2(5,5))		#scale the death animation
		$AnimationHandler.global_position.y -= 75		#correct the position relative to the tanks center
		$AnimationHandler.global_rotation = 0			#force the rotation of the animation to be upwards
		$AnimationHandler.play("tankExplosion")			#plays the fireExplosion animation from the animatedSprite node
	else:
		queue_free()

func _on_animation_handler_animation_finished():			#when animation signals that it has finished
	$AnimationHandler.hide()								#always hide the explosion once the animation is finished
	queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_entered():
	onScreen = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	onScreen = false
