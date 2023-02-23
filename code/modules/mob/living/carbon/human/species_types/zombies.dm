#define REGENERATION_DELAY 6 SECONDS  // After taking damage, how long it takes for automatic regeneration to begin

/datum/species/zombie
	// 1spooky
	name = "High-Functioning Zombie"
	id = "zombie"
	say_mod = "moans"
	sexes = FALSE
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	species_traits = list(NOBLOOD,NOZOMBIE,NOTRANSSTING,HAS_FLESH,HAS_BONE,AGENDER)
	inherent_traits = list(TRAIT_STABLELIVER, TRAIT_STABLEHEART, TRAIT_RESISTCOLD ,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_EASYDISMEMBER,TRAIT_EASILY_WOUNDED,TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NODEATH,TRAIT_FAKEDEATH)
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	mutanttongue = /obj/item/organ/tongue/zombie
	var/static/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW | MICE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | ERT_SPAWN

/datum/species/zombie/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/zombie/infectious
	name = "Infectious Zombie"
	id = "memezombies"
	limbs_id = "zombie"
	inherent_traits = list(TRAIT_STABLELIVER, TRAIT_STABLEHEART, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_EASILY_WOUNDED,TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NODEATH,TRAIT_FAKEDEATH,TRAIT_STUNIMMUNE)
	mutanthands = /obj/item/zombie_hand
	armor = 20 // 120 damage to KO a zombie, which kills it
	speedmod = 1.6
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie
	var/heal_rate = 1
	COOLDOWN_DECLARE(regen_cooldown)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

/datum/species/zombie/infectious/check_roundstart_eligible()
	return FALSE


/datum/species/zombie/infectious/spec_stun(mob/living/carbon/human/H,amount)
	. = min(2 SECONDS, amount)

/datum/species/zombie/infectious/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE)
	. = ..()
	if(.)
		COOLDOWN_START(src, regen_cooldown, REGENERATION_DELAY)

/datum/species/zombie/infectious/spec_life(mob/living/carbon/C)
	. = ..()
	C.a_intent = INTENT_HARM // THE SUFFERING MUST FLOW

	//Zombies never actually die, they just fall down until they regenerate enough to rise back up.
	//They must be restrained, beheaded or gibbed to stop being a threat.
	if(COOLDOWN_FINISHED(src, regen_cooldown))
		var/heal_amt = heal_rate
		if(C.InCritical())
			heal_amt *= 2
		C.heal_overall_damage(heal_amt,heal_amt)
		C.adjustToxLoss(-heal_amt)
		for(var/i in C.all_wounds)
			var/datum/wound/iter_wound = i
			if(prob(4-iter_wound.severity))
				iter_wound.remove_wound()
	if(!C.InCritical() && prob(4))
		playsound(C, pick(spooks), 50, TRUE, 10)

//Congrats you somehow died so hard you stopped being a zombie
/datum/species/zombie/infectious/spec_death(mob/living/carbon/C)
	. = ..()
	var/obj/item/organ/zombie_infection/infection
	infection = C?.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(infection)
		qdel(infection)

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()

	// Deal with the source of this zombie corruption
	//  Infection organ needs to be handled separately from mutant_organs
	//  because it persists through species transitions
	var/obj/item/organ/zombie_infection/infection
	infection = C.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new()
		infection.Insert(C)

// Your skin falls off
/datum/species/krokodil_addict
	name = "Human"
	id = "goofzombies"
	limbs_id = "zombie" //They look like zombies
	sexes = FALSE
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	mutanttongue = /obj/item/organ/tongue/zombie
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

//The special zombie you get turned into in the zombie gamemode
/datum/species/zombie/infectious/gamemode
	armor = 20
	brutemod = 0.925
	burnmod = 0.925
	speedmod = 1.45
	mutanthands = /obj/item/zombie_hand/gamemode
	inherent_traits = list(
	TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, 
	TRAIT_RESISTDAMAGESLOWDOWN, TRAIT_STABLELIVER, TRAIT_STABLEHEART,
	TRAIT_RADIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_NOBREATH, 
	TRAIT_NODEATH, TRAIT_FAKEDEATH, TRAIT_NOHUNGER,
	TRAIT_RESISTHEAT, TRAIT_SHOCKIMMUNE, TRAIT_PUSHIMMUNE, 
	TRAIT_STUNIMMUNE, TRAIT_BADDNA, TRAIT_EASILY_WOUNDED, TRAIT_EASYDISMEMBER)
	var/infection_regen = 0 //to set for special zombies

/datum/species/zombie/infectious/gamemode/spec_AltClickOn(atom/A, mob/living/carbon/human/H)
	if(!IS_SPECIALINFECTED(H)) //only special ones
		return
	var/datum/antagonist/zombie/zombie_owner = H.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!ishuman(A))
		return
	var/mob/living/carbon/human/target = A
	if(INTERACTING_WITH(H, target))
		to_chat(H, span_warning("You are too busy to infect [target.p_them()]!"))
		return
	to_chat(H, span_notice("You start inserting spores into [target]s ear canal..."))
	var/infect_time = (6 SECONDS / max(target.stat, 1)) // alive = 6, soft crit = 6, unconcious = 3, dead = 2
	if(!do_after(H, infect_time, target))
		to_chat(H, span_warning("You were interrupted and lost the entryway!"))
		return 
	to_chat(H, span_notice("You sucessfully infect [target]!"))
	zombie_owner.advance_progress()
	try_to_zombie_infect(target, /obj/item/organ/zombie_infection/gamemode)

/datum/species/zombie/infectious/gamemode/on_species_gain(mob/living/carbon/human/H)
	if(subtypesof(/datum/species/zombie/infectious/gamemode)) // we use general ones for general zombies
		H.draw_yogs_parts(TRUE) //to not fill the general one with zombe sprites (human_parts --> mutant_parts)
	inherent_traits = list(
	TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, 
	TRAIT_RESISTDAMAGESLOWDOWN, TRAIT_STABLELIVER, TRAIT_STABLEHEART,
	TRAIT_RADIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_NOBREATH, 
	TRAIT_NODEATH, TRAIT_FAKEDEATH, TRAIT_NOHUNGER,
	TRAIT_RESISTHEAT, TRAIT_SHOCKIMMUNE, TRAIT_PUSHIMMUNE, 
	TRAIT_STUNIMMUNE, TRAIT_BADDNA, TRAIT_EASILY_WOUNDED, TRAIT_NODISMEMBER) //devilish
	. = ..()

/datum/species/zombie/infectious/gamemode/on_species_loss(mob/living/carbon/human/H)
	if(subtypesof(/datum/species/zombie/infectious/gamemode))
		H.draw_yogs_parts(FALSE) //returns us to general file
	inherent_traits = list(
	TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, 
	TRAIT_RESISTDAMAGESLOWDOWN, TRAIT_STABLELIVER, TRAIT_STABLEHEART,
	TRAIT_RADIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_NOBREATH, 
	TRAIT_NODEATH, TRAIT_FAKEDEATH, TRAIT_NOHUNGER,
	TRAIT_RESISTHEAT, TRAIT_SHOCKIMMUNE, TRAIT_PUSHIMMUNE, 
	TRAIT_STUNIMMUNE, TRAIT_BADDNA, TRAIT_EASILY_WOUNDED, TRAIT_EASYDISMEMBER) //update it
	. = ..()

/datum/species/zombie/infectious/gamemode/runner
	limbs_id = "runner"
	mutanthands = /obj/item/zombie_hand/gamemode/runner
	armor = 15 // 110 damage to KO a zombie, which kills it
	speedmod = 0.45
	brutemod = 1
	infection_regen = 0.5 //per move

/datum/species/zombie/infectious/gamemode/juggernaut
	limbs_id = "juggernaut"
	mutanthands = /obj/item/zombie_hand/gamemode/tank
	armor = 35 // 135 damage to KO a zombie, which kills it
	brutemod = 0.75
	speedmod = 1.3
	heal_rate = 1.20
	infection_regen = 5 //inversely proportional to how much you actually get, so less = better, per damage

/datum/species/zombie/infectious/gamemode/spitter
	limbs_id = "spitter"
	mutanthands = /obj/item/zombie_hand/gamemode/spitter
	armor = 20 // 120 damage to KO a zombie, which kills it
	brutemod = 1
	burnmod = 1
	infection_regen = 2 //passive

///Delay for infection points to regenerate after deactivating the ability.
#define SMOKER_REGEN_DELAY 5 SECONDS

/datum/species/zombie/infectious/gamemode/smoker
	limbs_id = "smoker"
	mutanthands = /obj/item/zombie_hand/gamemode/smoker
	armor = 15
	infection_regen = 2.5 //passive

/*
* Smokers and Spitters regenerate infection points naturally.
*/
/datum/species/zombie/infectious/gamemode/smoker/spec_life(mob/living/carbon/C)
	. = ..()
	if(!IS_INFECTED(C))
		return
	var/datum/antagonist/zombie/Z = C.mind.has_antag_datum(/datum/antagonist/zombie)
	var/datum/action/innate/zombie/default/smoke/ability = locate() in Z.zombie_abilities
	if(ability?.last_fired > world.time - SMOKER_REGEN_DELAY)
		return
	if(Z.infection_max - Z.infection >= infection_regen)
		Z.manage_infection(-infection_regen)
	else
		Z.manage_infection(Z.infection - Z.infection_max)

/datum/species/zombie/infectious/gamemode/spitter/spec_life(mob/living/carbon/C)
	. = ..()
	if(!IS_INFECTED(C))
		return
	var/datum/antagonist/zombie/Z = C.mind.has_antag_datum(/datum/antagonist/zombie)
	if(Z.infection_max - Z.infection >= infection_regen)
		Z.manage_infection(-infection_regen)
	else
		Z.manage_infection(Z.infection - Z.infection_max)

#undef SMOKER_REGEN_DELAY

/*
* Juggs gain infection points when harmed.
*/
/datum/species/zombie/infectious/gamemode/juggernaut/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, wound_bonus = 0, bare_wound_bonus = 0, sharpness = FALSE)
	var/obj/item/zombie_hand/gamemode/tank/hand = H.get_active_held_item() || H.get_inactive_held_item()
	if(!hand.is_stub && hand.defensive_mode && def_zone != BODY_ZONE_L_ARM && prob(35))
		def_zone = BODY_ZONE_L_ARM //35% chance to arm to take damage if defensive
	. = ..()
	if(!.)
		return
	if(damagetype == TOX) //cheeky bastard, do not consume plasma!
		return
	var/datum/antagonist/zombie/Z = H.mind.has_antag_datum(/datum/antagonist/zombie)
	if(Z.infection_max - Z.infection >= damage / infection_regen)
		Z.manage_infection(-damage / infection_regen)
	else
		Z.manage_infection(Z.infection - Z.infection_max)

/datum/species/zombie/infectious/gamemode/spec_stun(mob/living/carbon/human/H,amount)
	. = 0

/datum/species/zombie/infectious/gamemode/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, wound_bonus = 0, bare_wound_bonus = 0, sharpness = FALSE)
	if(damagetype == STAMINA)
		return
	. = ..()
	if(.)
		COOLDOWN_START(src, regen_cooldown, REGENERATION_DELAY)

/*
* Runners gain infection points on move.
*/
/datum/species/zombie/infectious/gamemode/runner/on_species_gain(mob/living/carbon/human/H)
	RegisterSignal(H, COMSIG_MOVABLE_MOVED, .proc/on_move)
	. = ..()

/datum/species/zombie/infectious/gamemode/on_species_loss(mob/living/carbon/human/H)
	UnregisterSignal(H, COMSIG_MOVABLE_MOVED)
	. = ..()

/datum/species/zombie/infectious/gamemode/runner/proc/on_move(mob/living/carbon/human/H)
	var/datum/antagonist/zombie/Z = H.mind.has_antag_datum(/datum/antagonist/zombie)
	if(Z.infection_max - Z.infection >= infection_regen)
		Z.manage_infection(-infection_regen)
	else
		Z.manage_infection(Z.infection - Z.infection_max)

/datum/species/zombie/infectious/gamemode/coordinator
	armor = 17
	speedmod = 1.2

/datum/species/zombie/infectious/gamemode/necromancer
	mutanthands = /obj/item/zombie_hand/gamemode/necro
	armor = 10
	speedmod = 1.2

/datum/species/zombie/infectious/gamemode/necromanced_minion
	var/mob/living/carbon/human/master
	var/max_distance = 1 //Default value
	armor = 10
	brutemod = 1.05
	burnmod = 1.05
	species_traits = list(NO_UNDERWEAR, NOBLOOD, NOZOMBIE, NOTRANSSTING, HAS_FLESH, HAS_BONE)
	inherent_traits = list(TRAIT_EASYDISMEMBER, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE,
	TRAIT_RADIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_NOBREATH, TRAIT_NODEATH, TRAIT_FAKEDEATH, TRAIT_NOHUNGER, TRAIT_RESISTHEAT, TRAIT_SHOCKIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_STUNIMMUNE, TRAIT_BADDNA, TRAIT_EASILY_WOUNDED)

/datum/species/zombie/infectious/gamemode/necromanced_minion/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(prob(50) && !H.stat)
		if(get_dist(get_turf(master), get_turf(H)) > max_distance)
			if(prob(20))
				to_chat(H, span_userdanger("You are too far away from your master! You are taking damage!"))
			apply_damage(7.5, BRUTE, null, FALSE, H)

		if(master.stat == DEAD || QDELETED(master))
			to_chat(H, span_userdanger("Your master is dead. And with his death, comes yours!"))
			H.dust()

#undef REGENERATION_DELAY
