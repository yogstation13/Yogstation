/obj/mecha/combat/sidewinder
	desc = "A squat, nimble, and rather confining exosuit taking advantage of advanced synthetic muscles to move around. Originally used for entertainment in mech \"sports\", many have found it to be well-suited for more practical applications."
	name = "\improper Sidewinder"
	icon_state = "sidewinder"
	step_in = 2.5	//Faster than a gygax
	dir_in = 1		//Facing North.
	force = 15
	max_integrity = 200
	deflect_chance = 10
	armor = list(MELEE = 40, BULLET = 20, LASER = 20, ENERGY = 15, BOMB = 40, BIO = 100, RAD = 75, FIRE = 100, ACID = 100)	//Good for harsh environments, less good vs gun
	max_temperature = 25000
	infra_luminosity = 6
	wreckage = /obj/structure/mecha_wreckage/sidewinder
	internal_damage_threshold = 25	//Reinforced internal components
	max_equip = 3
	step_energy_drain = 3
	guns_allowed = FALSE			//Melee only
	omnidirectional_attacks = TRUE	//Thus the name
	melee_cooldown = 7
	turnsound = 'sound/mecha/mechmove01.ogg'

/obj/mecha/combat/sidewinder/click_action(atom/target,mob/user,params)
	//Check all this stuff because this has to happen BEFORE we call the parent so that we can sword in the right direction
	if(!occupant || occupant != user )					//No pilot
		return
	if(!locate(/turf) in list(target,target.loc)) 		//Prevents inventory from being drilled
		return
	if(user.incapacitated())							//Pilot can't move
		return
	if(completely_disabled || is_currently_ejecting)	//mech can't move
		return
	if(state)											//Maintenance mode, can't move
		occupant_message(span_warning("Maintenance protocols in effect."))
		return
	if(!get_charge())									//No power, can't move
		return
	if(src == target)									//We can't face ourselves
		return
	if(!equipment_disabled)								//EMP will disable the turning temporarily
		var/initial_direction = dir
		face_atom(target)
		var/new_direction = dir	
		if(initial_direction != new_direction)			//Make sure we actually turned
			playsound(src,'sound/mecha/mechmove01.ogg',40,1)
	return ..()
