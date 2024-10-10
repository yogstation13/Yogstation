#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin

/datum/species/zombie
	// 1spooky
	name = "High-Functioning Zombie"
	id = SPECIES_ZOMBIE
	say_mod = "moans"
	possible_genders = list(NEUTER)
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	species_traits = list(NOBLOOD, NOZOMBIE, NOTRANSSTING, HAS_FLESH, HAS_BONE)
	inherent_traits = list(TRAIT_STABLELIVER, TRAIT_STABLEHEART, TRAIT_RESISTCOLD ,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_EASYDISMEMBER,TRAIT_EASILY_WOUNDED,TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NODEATH,TRAIT_FAKEDEATH)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutanttongue = /obj/item/organ/tongue/zombie
	var/static/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW | MICE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | ERT_SPAWN

/datum/species/zombie/check_roundstart_eligible()
	if(SSgamemode.holidays && SSgamemode.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/zombie/get_species_description()
	return "A rotting zombie! They descend upon Space Station Thirteen Every year to spook the crew! \"Sincerely, the Zombies!\""

/datum/species/zombie/get_species_lore()
	return list("Zombies have long lasting beef with Botanists. Their last incident involving a lawn with defensive plants has left them very unhinged.")

// Override for the default temperature perks, so we can establish that they don't care about temperature very much
/datum/species/zombie/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-half",
		SPECIES_PERK_NAME = "No Body Temperature",
		SPECIES_PERK_DESC = "Having long since departed, Zombies do not have anything \
			regulating their body temperature anymore. This means that \
			the environment decides their body temperature - which they don't mind at \
			all, until it gets a bit too hot.",
	))

	return to_add

/datum/species/zombie/infectious
	name = "Infectious Zombie"
	id = SPECIES_ZOMBIE_INFECTIOUS
	limbs_id = SPECIES_ZOMBIE
	inherent_traits = list(TRAIT_STABLELIVER, TRAIT_STABLEHEART, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_EASILY_WOUNDED,TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NODEATH,TRAIT_FAKEDEATH,TRAIT_STUNIMMUNE)
	mutanthands = /obj/item/zombie_hand
	armor = 20 // 120 damage to KO a zombie, which kills it
	speedmod = 1.6
	mutanteyes = /obj/item/organ/eyes/zombie
	var/heal_rate = 1
	var/regen_cooldown = 0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

/datum/species/zombie/infectious/check_roundstart_eligible()
	return FALSE


/datum/species/zombie/infectious/spec_stun(mob/living/carbon/human/H,amount)
	. = min(20, amount)

/datum/species/zombie/infectious/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE, attack_direction = null)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/datum/species/zombie/infectious/spec_life(mob/living/carbon/C)
	. = ..()
	C.set_combat_mode(TRUE, TRUE) // THE SUFFERING MUST FLOW

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
/datum/species/zombie/infectious/spec_death(mob/living/carbon/C)
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
	id = SPECIES_ZOMBIE_KROKODIL
	limbs_id = SPECIES_ZOMBIE //They look like zombies
	possible_genders = list(PLURAL)
	species_traits = list(HAS_FLESH, HAS_BONE)
	inherent_traits = list(TRAIT_EASILY_WOUNDED) //you have no skin
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID //pretty much just rotting flesh, somehow still "technically" alive
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	mutanttongue = /obj/item/organ/tongue/zombie
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

//Hecata necromancy bloodsucker zombie. Kind of like a weakened Szlachta that can also wear clothes still
/datum/species/zombie/hecata
	name = "Sanguine Zombie"
	id = "hecatazombie"
	limbs_id = SPECIES_ZOMBIE
	say_mod = "moans"
	brutemod = 1.1
	burnmod = 1.1 //more fragile, though they also dont enter soft crit
	brutemod = 1.1 //more fragile, though they also dont enter soft crit.
	speedmod = 0.33 //slightly slower
	stunmod = 0.5
	staminamod = 0.5 //difficult to subdue via nonlethal means
	punchdamagelow = 13
	punchdamagehigh = 16
	punchstunthreshold = 17 //pretty good punch damage but no knockdown
	///no guns or soft crit
	inherent_traits = list(
		TRAIT_STABLELIVER,
		TRAIT_STABLEHEART,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_EASYDISMEMBER,
		TRAIT_EASILY_WOUNDED,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBREATH,
		TRAIT_NODEATH,
		TRAIT_FAKEDEATH,
		TRAIT_NOGUNS,
		TRAIT_NOSOFTCRIT,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

/datum/species/zombie/hecata/on_species_gain(mob/living/carbon/mob_changing_species, datum/species/old_species)
	. = ..()
	mob_changing_species.faction |= "bloodhungry"

/datum/species/zombie/hecata/on_species_loss(mob/living/carbon/mob_changing_species)
	. = ..()
	mob_changing_species.faction -= "bloodhungry"

#undef REGENERATION_DELAY
