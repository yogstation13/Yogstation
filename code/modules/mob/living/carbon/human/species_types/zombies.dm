#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin

/datum/species/zombie
	// 1spooky
	name = "High-Functioning Zombie"
	id = "zombie"
	say_mod = "moans"
	sexes = 0
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	species_traits = list(NOBLOOD,NOZOMBIE,NOTRANSSTING,HAS_FLESH,HAS_BONE)
	inherent_traits = list(TRAIT_STABLELIVER, TRAIT_STABLEHEART, TRAIT_RESISTCOLD ,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_EASYDISMEMBER,TRAIT_EASILY_WOUNDED,TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NO,TRAIT_FAKE)
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
	inherent_traits = list(TRAIT_STABLELIVER, TRAIT_STABLEHEART, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_EASILY_WOUNDED,TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NO,TRAIT_FAKE,TRAIT_STUNIMMUNE)
	mutanthands = /obj/item/zombie_hand
	armor = 20 // 120 damage to KO a zombie, which kills it
	speedmod = 1.6
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie
	var/heal_rate = 1
	var/regen_cooldown = 0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

/datum/species/zombie/infectious/check_roundstart_eligible()
	return FALSE


/datum/species/zombie/infectious/spec_stun(mob/living/carbon/human/H,amount)
	. = min(20, amount)

/datum/species/zombie/infectious/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/datum/species/zombie/infectious/spec_life(mob/living/carbon/C)
	. = ..()
	C.a_intent = INTENT_HARM // THE SUFFERING MUST FLOW

	//Zombies never actually die, they just fall down until they regenerate enough to rise back up.
	//They must be restrained, beheaded or gibbed to stop being a threat.
	if(regen_cooldown < world.time)
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
/datum/species/zombie/infectious/spec_(mob/living/carbon/C)
	. = ..()
	var/obj/item/organ/zombie_infection/infection
	infection = C.getorganslot(ORGAN_SLOT_ZOMBIE)
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
	sexes = 0
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
	inherent_traits = list(TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTDAMAGESLOWDOWN, TRAIT_STABLELIVER, TRAIT_STABLEHEART,
	TRAIT_RADIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_NOBREATH, TRAIT_NO, TRAIT_FAKE, TRAIT_NOHUNGER, TRAIT_RESISTHEAT, TRAIT_SHOCKIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_STUNIMMUNE, TRAIT_BADDNA, TRAIT_EASILY_WOUNDED, TRAIT_EASYDISMEMBER)
	no_equip = list(SLOT_WEAR_MASK, SLOT_GLASSES, SLOT_HEAD)

/datum/species/zombie/infectious/gamemode/runner
	mutanthands = /obj/item/zombie_hand/gamemode/runner
	armor = 10 // 110 damage to KO a zombie, which kills it
	speedmod = 0.45
	brutemod = 1

/datum/species/zombie/infectious/gamemode/juggernaut
	mutanthands = /obj/item/zombie_hand/gamemode/tank
	armor = 30 // 135 damage to KO a zombie, which kills it
	brutemod = 0.75
	speedmod = 1.3
	heal_rate = 1.20

/datum/species/zombie/infectious/gamemode/spitter
	armor = 5 // 110 damage to KO a zombie, which kills it
	brutemod = 1
	burnmod = 1

/datum/species/zombie/infectious/gamemode/spec_stun(mob/living/carbon/human/H,amount)
	. = 0

/datum/species/zombie/infectious/gamemode/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, wound_bonus = 0, bare_wound_bonus = 0, sharpness = FALSE)
	if(damagetype == STAMINA)
		return
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY


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
	TRAIT_RADIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_NOBREATH, TRAIT_NO, TRAIT_FAKE, TRAIT_NOHUNGER, TRAIT_RESISTHEAT, TRAIT_SHOCKIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_STUNIMMUNE, TRAIT_BADDNA, TRAIT_EASILY_WOUNDED)

/datum/species/zombie/infectious/gamemode/necromanced_minion/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(prob(50) && !H.stat)
		if(get_dist(get_turf(master), get_turf(H)) > max_distance)
			if(prob(20))
				to_chat(H, span_userdanger("You are too far away from your master! You are taking damage!"))
			apply_damage(7.5, BRUTE, null, FALSE, H)

		if(master.stat == DEAD || QDELETED(master))
			to_chat(H, span_userdanger("Your master is dead. And with his , comes yours!"))
			H.dust()

#undef REGENERATION_DELAY
