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
	//Attack sound for the weapon
	var/attack_sound
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
	//If we have both cleave and precise attacks, the precise may have more damage
	var/precise_weapon_damage = 0
	//Bonus deflection chance for using a melee weapon capable of blocking attacks
	var/deflect_bonus = 0
	//Base armor piercing value of the weapon
	var/base_armor_piercing = 0
	//Fauna bonus damage, if any
	var/fauna_damage_bonus = 0
	//Structure damage multiplier, for stuff like big ol' smashy hammers. Base structure damage multiplier for mech melee attacks is 3.
	var/structure_damage_mult = 3

    var/cleave_effect = /obj/effect/temp_visual/dir_setting/mecha_swipe
	var/attack_effect = /obj/effect/

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
			cleave_attack()			//Or swing wildly if we can't
	chassis.log_message("Attacked with [src.name], targeting [target].", LOG_MECHA)
	return 1

/obj/item/mecha_parts/mecha_equipment/melee_weapon/proc/precise_attack(atom/target)	//No special attack by default. These will be set in the weapons themselves
	return 0

/obj/item/mecha_parts/mecha_equipment/melee_weapon/proc/cleave_attack()
	return 0

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword
	name = "generic mech sword"
	desc = "Generic mech sword! It's a bit too big to use yourself."
	cleave = TRUE
	precise_attack = TRUE
	attack_sharpness = SHARP_EDGED
	attack_sound = 'sound/weapons/bladeslice.ogg'
	var/minimum_damage = 0			//Baby mechs with a scret combat module get a little boost

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/shortsword	//Our bread-and-butter mech shortsword for both slicing and stabbing baddies
	name = "\improper GD6 \"Jaeger\" shortsword"
	desc = "An extendable arm-mounted blade with a nasty edge. It is small and fast enough to deflect some incoming attacks."
	weapon_damage = 10
	precise_weapon_damage = 15
	fauna_damage_bonus = 30		//because why not
	deflect_bonus = 15
	base_armor_piercing = 15
	structure_damage_mult = 2	//Sword is not as smashy
	minimum_damage = 25			

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/cleave_attack()
	var/turf/M = get_turf(src)
	var/list/attack_turfs = list()
	for(var/i = 0 to 2)
		var/turf/T = get_step(M,turn(chassis.dir + (45(1-i))))	//+45, +0, and -45 will get the three front tiles
		for(var/atom/A in T.contents)
			if(isliving(A))						
				var/mob/living/L = A
				
				if(iscarbon(L))					//If we're a carbon we can get armor and jazz
					var/mob/living/carbon/C = L
					var/obj/item/bodypart/body_part = pick(C.bodyparts)	//Cleave attack isn't very precise
					var/armor_block = C.run_armor_check(body_part, MELEE, armour_penetration = base_armor_piercing)
					C.apply_damage(max(chassis.force + weapon_damage, minimum_damage), dam_type, body_part, armor_block, sharpness = attack_sharpness)

				else							//Regular mobs just take damage
					L.apply_damage(max(chassis.force + weapon_damage, minimum_damage), dam_type)
					if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))	//If we're hitting fauna, because heck those guys
						L.apply_damage(fauna_damage_bonus, dam_type)

				L.visible_message(span_danger("[chassis] strikes [L] with a wide swing of its [src]!"), \
				  span_userdanger("[chassis] strikes you with [src]!"))
				chassis.log_message("Hit [L] with [src.name] (cleave attack).", LOG_MECHA)

			else if(isstructure(A) || ismachinery(A))	//if it's something we can otherwise still hit
				var/obj/structure/S = A
				if(!A.density)							//Make sure it's not an open door or something
					continue
				var/structure_damage = max(chassis.force + weapon_damage, minimum_damage) * structure_damage_mult
				S.take_damage(structure_damage, dam_type, "melee", 0)

	new attack_effect(get_turf(src), chassis.dir)
	playsound(chassis, attack_sound, 50, 1)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/precise_attack(atom/target)
	if(isliving(A))						
		var/mob/living/L = A

		if(iscarbon(L))
			var/mob/living/carbon/C = L
			var/obj/item/bodypart/body_part = chassis.occupant.selected_zone	//Precise attacks can be aimed
			var/armor_block = C.run_armor_check(body_part, MELEE, armour_penetration = base_armor_piercing * 2)	//and get more AP
			C.apply_damage(max(chassis.force + precise_weapon_damage, minimum_damage), dam_type, body_part, armor_block, sharpness = attack_sharpness)

		else
			L.apply_damage(max(chassis.force + precise_weapon_damage, minimum_damage), dam_type)
			if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))	//Stab them harder
				L.apply_damage(fauna_damage_bonus, dam_type)

		L.visible_message(span_danger("[chassis] strikes [L] with its [src]!"), \
				  span_userdanger("[chassis] strikes you with [src]!"))
				chassis.log_message("Hit [L] with [src.name] (precise attack).", LOG_MECHA)

		else if(isstructure(A) || ismachinery(A))	//If the initial target is a structure, hit it regardless of if it's dense or not.
				var/obj/structure/S = A
				var/structure_damage = max(chassis.force + precise_weapon_damage, minimum_damage) * structure_damage_mult
				S.take_damage(structure_damage, dam_type, "melee", 0)
		else
			return
		chassis.do_attack_animation(A, ATTACK_EFFECT_SLASH)
		playsound(chassis, attack_sound, 50, 1)
