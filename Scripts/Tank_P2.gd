extends Tank
#extends "res://Scripts/MasterTank.gd"

@onready var HUDpath = $"../../GameInfo/HUD"
@onready var INVpath = HUDpath.get_node("P2_Inv")

func _process(delta):
	super(delta)			#Call self in parent
	handleHUDPowerUps() 

func handleHUDPowerUps():
	if invincible:
		INVpath.get_node("P2_Invincible").show()
	elif not invincible:
		INVpath.get_node("P2_Invincible").hide()
		
	if shieldUp:
		INVpath.get_node("P2_Shield").show()
	elif not shieldUp:
		INVpath.get_node("P2_Shield").hide()
		
	if speedUp:
		INVpath.get_node("P2_SpeedUp").show()
	elif not speedUp:
		INVpath.get_node("P2_SpeedUp").hide()
			
	if slowDown:
		INVpath.get_node("P2_SlowDown").show()
	elif not slowDown:
		INVpath.get_node("P2_SlowDown").hide()
			
	if isFrozen:
		INVpath.get_node("P2_Freeze").show()
	elif not isFrozen:
		INVpath.get_node("P2_Freeze").hide()
			
	if controlsReversed:
		INVpath.get_node("P2_Reverse").show()
	elif not controlsReversed:
		INVpath.get_node("P2_Reverse").hide()
			
	if shootRocket > 0:
		INVpath.get_node("P2_Rocket").show()
	elif shootRocket <= 0:
		INVpath.get_node("P2_Rocket").hide()
			
	if shootWide > 0:
		INVpath.get_node("P2_Wide").show()
	elif shootWide <= 0:
		INVpath.get_node("P2_Wide").hide()
			
	if shootPiercing > 0:
		INVpath.get_node("P2_Piercing").show()
	elif shootPiercing <= 0:
		INVpath.get_node("P2_Piercing").hide()
			
	if shootTriple > 0:
		INVpath.get_node("P2_Triple").show()
	elif shootTriple <= 0:
		INVpath.get_node("P2_Triple").hide()
		
	if shootGrenade > 0:
		INVpath.get_node("P2_Grenade").show()
	elif shootGrenade <= 0:
		INVpath.get_node("P2_Grenade").hide()
		
	if shootBouncy > 0:
		INVpath.get_node("P2_Bouncy").show()
	elif shootBouncy <= 0:
		INVpath.get_node("P2_Bouncy").hide()	
		
	if rapidFire:
		INVpath.get_node("P2_RapidFire").show()
	elif not rapidFire:
		INVpath.get_node("P2_RapidFire").hide()
			
	if isMini:
		INVpath.get_node("P2_Mini").show()
	elif not isMini:
		INVpath.get_node("P2_Mini").hide()
			
	if ultiMode:
		#Needs to actiavte more things as the last check, but not deactivate them as they wll be deactivated as early as the next frame 
		INVpath.get_node("P2_Ultimate").show()
		INVpath.get_node("P2_Invincible").show()
		INVpath.get_node("P2_RapidFire").show()
		INVpath.get_node("P2_Freeze").show()
	elif not ultiMode:
		INVpath.get_node("P2_Ultimate").hide()
		INVpath.get_node("P2_Piercing").hide()
		

func _on_health_change(value):
	HUDpath.healthBarUpdateP2(value)				#to update the HUD health for P2
