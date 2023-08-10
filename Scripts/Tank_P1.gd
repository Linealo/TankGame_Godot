extends Tank
#extends "res://Scripts/MasterTank.gd"

func _process(delta):
	super(delta)			#Call self in parent
	handleHUDPowerUps() 

func handleHUDPowerUps():
	if invincible:
		$"../HUD/P1_Inv/P1_Invincible".show()
	elif not invincible:
		$"../HUD/P1_Inv/P1_Invincible".hide()
		
	if shieldUp:
		$"../HUD/P1_Inv/P1_Shield".show()
	elif not shieldUp:
		$"../HUD/P1_Inv/P1_Shield".hide()
		
	if speedUp:
		$"../HUD/P1_Inv/P1_SpeedUp".show()
	elif not speedUp:
		$"../HUD/P1_Inv/P1_SpeedUp".hide()
			
	if slowDown:
		$"../HUD/P1_Inv/P1_SlowDown".show()
	elif not slowDown:
		$"../HUD/P1_Inv/P1_SlowDown".hide()
			
	if isFrozen:
		$"../HUD/P1_Inv/P1_Freeze".show()
	elif not isFrozen:
		$"../HUD/P1_Inv/P1_Freeze".hide()
			
	if controlsReversed:
		$"../HUD/P1_Inv/P1_Reverse".show()
	elif not controlsReversed:
		$"../HUD/P1_Inv/P1_Reverse".hide()
			
	if shootRocket > 0:
		$"../HUD/P1_Inv/P1_Rocket".show()
	elif shootRocket <= 0:
		$"../HUD/P1_Inv/P1_Rocket".hide()
			
	if shootWide > 0:
		$"../HUD/P1_Inv/P1_Wide".show()
	elif shootWide <= 0:
		$"../HUD/P1_Inv/P1_Wide".hide()
			
	if shootPiercing > 0:
		$"../HUD/P1_Inv/P1_Piercing".show()
	elif shootPiercing <= 0:
		$"../HUD/P1_Inv/P1_Piercing".hide()
			
	if shootTriple > 0:
		$"../HUD/P1_Inv/P1_Triple".show()
	elif shootTriple <= 0:
		$"../HUD/P1_Inv/P1_Triple".hide()
		
	if shootGrenade > 0:
		$"../HUD/P1_Inv/P1_Grenade".show()
	elif shootGrenade <= 0:
		$"../HUD/P1_Inv/P1_Grenade".hide()
		
	if shootBouncy > 0:
		$"../HUD/P1_Inv/P1_Bouncy".show()
	elif shootBouncy <= 0:
		$"../HUD/P1_Inv/P1_Bouncy".hide()	
		
	if rapidFire:
		$"../HUD/P1_Inv/P1_RapidFire".show()
	elif not rapidFire:
		$"../HUD/P1_Inv/P1_RapidFire".hide()
			
	if isMini:
		$"../HUD/P1_Inv/P1_Mini".show()
	elif not isMini:
		$"../HUD/P1_Inv/P1_Mini".hide()
			
	if ultiMode:
		#Needs to actiavte more things as the last check, but not deactivate them as they wll be deactivated as early as the next frame 
		$"../HUD/P1_Inv/P1_Ultimate".show()
		$"../HUD/P1_Inv/P1_Invincible".show()
		$"../HUD/P1_Inv/P1_RapidFire".show()
		$"../HUD/P1_Inv/P1_Freeze".show()
	elif not ultiMode:
		$"../HUD/P1_Inv/P1_Ultimate".hide()
		$"../HUD/P1_Inv/P1_Piercing".hide()
		

func _on_health_change(value):
	$"../HUD".healthBarUpdateP1(value)				#to update the HUD health for P1
