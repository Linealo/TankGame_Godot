extends Tank
#extends "res://Scripts/MasterTank.gd"

func _process(delta):
	super(delta)			#Call self in parent
	handleHUDPowerUps() 

func handleHUDPowerUps():
	if invincible:
		$"../HUD/P2_Inv/P2_Invincible".show()
	elif not invincible:
		$"../HUD/P2_Inv/P2_Invincible".hide()
		
	if shieldUp:
		$"../HUD/P2_Inv/P2_Shield".show()
	elif not shieldUp:
		$"../HUD/P2_Inv/P2_Shield".hide()
		
	if speedUp:
		$"../HUD/P2_Inv/P2_SpeedUp".show()
	elif not speedUp:
		$"../HUD/P2_Inv/P2_SpeedUp".hide()
			
	if slowDown:
		$"../HUD/P2_Inv/P2_SlowDown".show()
	elif not slowDown:
		$"../HUD/P2_Inv/P2_SlowDown".hide()
			
	if isFrozen:
		$"../HUD/P2_Inv/P2_Freeze".show()
	elif not isFrozen:
		$"../HUD/P2_Inv/P2_Freeze".hide()
			
	if controlsReversed:
		$"../HUD/P2_Inv/P2_Reverse".show()
	elif not controlsReversed:
		$"../HUD/P2_Inv/P2_Reverse".hide()
			
	if shootRocket > 0:
		$"../HUD/P2_Inv/P2_Rocket".show()
	elif shootRocket <= 0:
		$"../HUD/P2_Inv/P2_Rocket".hide()
			
	if shootWide > 0:
		$"../HUD/P2_Inv/P2_Wide".show()
	elif shootWide <= 0:
		$"../HUD/P2_Inv/P2_Wide".hide()
			
	if shootPiercing > 0:
		$"../HUD/P2_Inv/P2_Piercing".show()
	elif shootPiercing <= 0:
		$"../HUD/P2_Inv/P2_Piercing".hide()
			
	if shootTriple > 0:
		$"../HUD/P2_Inv/P2_Triple".show()
	elif shootTriple <= 0:
		$"../HUD/P2_Inv/P2_Triple".hide()
		
	if shootGrenade > 0:
		$"../HUD/P2_Inv/P2_Grenade".show()
	elif shootGrenade <= 0:
		$"../HUD/P2_Inv/P2_Grenade".hide()
		
	if shootBouncy > 0:
		$"../HUD/P2_Inv/P2_Bouncy".show()
	elif shootBouncy <= 0:
		$"../HUD/P2_Inv/P2_Bouncy".hide()	
		
	if rapidFire:
		$"../HUD/P2_Inv/P2_RapidFire".show()
	elif not rapidFire:
		$"../HUD/P2_Inv/P2_RapidFire".hide()
			
	if isMini:
		$"../HUD/P2_Inv/P2_Mini".show()
	elif not isMini:
		$"../HUD/P2_Inv/P2_Mini".hide()
			
	if ultiMode:
		#Needs to actiavte more things as the last check, but not deactivate them as they wll be deactivated as early as the next frame 
		$"../HUD/P2_Inv/P2_Ultimate".show()
		$"../HUD/P2_Inv/P2_Invincible".show()
		$"../HUD/P2_Inv/P2_RapidFire".show()
		$"../HUD/P2_Inv/P2_Freeze".show()
	elif not ultiMode:
		$"../HUD/P2_Inv/P2_Ultimate".hide()
		$"../HUD/P2_Inv/P2_Piercing".hide()
		

func _on_health_change(value):
	$"../HUD".healthBarUpdateP2(value)				#to update the HUD health for P2
