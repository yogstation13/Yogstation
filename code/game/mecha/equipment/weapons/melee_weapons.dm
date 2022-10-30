/obj/item/mecha_parts/mecha_equipment/melee_weapon
	name = "mecha melee weapon"
	range = MECHA_MELEE|MECHA_RANGED	//so we can do stuff at range and in melee
	destroy_sound = 'sound/mecha/weapdestr.ogg'
    mech_flags = EXOSUIT_MODULE_COMBAT
	melee_override = TRUE
	var/restricted = TRUE //for our special hugbox exofabs
	//If we have a longer range weapon, such as a spear or whatever capable of hitting people further away, this is how much extra range it has
	var/extended_range = 0
	//Attack speed modifier for a weapon. Big weapons will have a longer delay between attacks, while smaller ones will be faster
	var/attack_speed_modifier = 1

	//Attack types - Note that at least one of these must be true otherwise it's not actually a weapon and will have no effect
	//By default we assume we're using a small weapon with only a special single-target attack
    //If the weapon has an AOE attack
    var/cleave = FALSE
	//If the weapon has a single-target strike
	var/precise_attacks = TRUE


	//Damage type for the weapon
	var/dam_type = BRUTE
	//If it's sharp or not
	var/attack_sharpness = SHARP_NONE
	//Damage the weapon will do. Note this is ADDED to the base mecha attack damage (usually)
	var/weapon_damage = 0
	//Bonus deflection chance for using a melee weapon capable of blocking attacks
	var/deflect_bonus = 0


    var/attack_effect = /obj/effect/temp_visual/dir_setting/mecha_attack

/obj/item/mecha_parts/mecha_equipment/melee_weapon/can_attach(obj/mecha/M)
	if(!..())
		return FALSE
	if(istype(M, /obj/mecha/combat))
		return TRUE
	if((locate(/obj/item/mecha_parts/concealed_weapon_bay) in M.contents) && !((locate(/obj/item/mecha_parts/mecha_equipment/melee_weapon) in M.equipment) || (locate(/obj/item/mecha_parts/mecha_equipment/melee_weapon) in M.equipment) ))
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/melee_weapon/proc/start_cooldown()
	set_ready_state(0)
	chassis.use_power(energy_drain)
	addtimer(CALLBACK(src, .proc/set_ready_state, 1), chassis.melee_cooldown * attack_speed_modifer)	//Guns only shoot so fast, but weapons can be used as fast as the chassis can swing it!

//THIS ISNT EVEN CLOSE TO DONE YET 
//Melee weapon attacks are a little different in that they'll override the standard melee attack
/obj/item/mecha_parts/mecha_equipment/melee_weapon/action(atom/target, params)
	if(!action_checks(target))
		return 0

	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)
	if (!targloc || !istype(targloc) || !curloc)
		return 0
	if (targloc == curloc)
		return 0
	
	
	if(target == targloc && !(chassis.occupant.a_intent == INTENT_HELP))	//If we are targetting a location, not an object or mob, and we're not in a passive stance
		if(cleave)
			cleave_attack()
	else if(precise_attacks && (get_dist(src,target) <= (1 + extended_range)))	//If we are targetting not a turf and they're within reach
		precise_attack(target)		//We stab it if we can
		else
			cleave_attack()			//Or swing for the fences if we can't
	chassis.log_message("Attacked from [src.name], targeting [target].", LOG_MECHA)
	return 1

/obj/item/mecha_parts/mecha_equipment/melee_weapon/precise_attack(atom/target)	//No special attack by default. These will be set in the weapons themselves
	return 0

/obj/item/mecha_parts/mecha_equipment/melee_weapon/cleave_attack()
	return 0

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword
	name = "generic mech sword"
	desc = "Generic mech sword! It's a bit too big to use yourself."
	cleave = TRUE
	precise_attack = TRUE
	attack_sharpness = SHARP_EDGED

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/shortsword	//Our bread-and-butter mech shortsword for both slicing and stabbing baddies
	name = "\improper GD6 \"Jaeger\" shortsword"
	desc = "An extendable arm-mounted blade with a nasty edge. It is small and fast enough to deflect some incoming attacks."
	weapon_damage = 15
	deflect_bonus = 15

//hold onto this
//		new attack_effect(get_turf(src), chassis.dir)
//		playsound(chassis, fire_sound, 50, 1)
