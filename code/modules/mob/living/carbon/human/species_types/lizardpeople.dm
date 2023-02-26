/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Lizardperson"
	plural_form = "Lizardfolk"
	id = "lizard"
	say_mod = "hisses"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAS_TAIL)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_REPTILE)
	mutant_bodyparts = list("tail_lizard", "snout", "spines", "horns", "frills", "body_markings", "legs")
	mutanttongue = /obj/item/organ/tongue/lizard
	mutanttail = /obj/item/organ/tail/lizard
	coldmod = 1.75 //Desert-born race
	heatmod = 0.75 //Desert-born race
	payday_modifier = 0.85 //Full SIC citizens, but not quite given all the same rights- it's been an ongoing process for about half a decade
	default_features = list("mcolor" = "0F0", "tail_lizard" = "Smooth", "snout" = "Round", "horns" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None", "legs" = "Normal Legs")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = "L"
	disliked_food = SUGAR | VEGETABLES
	liked_food = MEAT | GRILLED | SEAFOOD | MICE
	inert_mutation = FIREBREATH
	deathsound = 'sound/voice/lizard/deathsound.ogg'
	screamsound = 'yogstation/sound/voice/lizardperson/lizard_scream.ogg' //yogs - lizard scream
	wings_icon = "Dragon"
	species_language_holder = /datum/language_holder/lizard
	var/heat_stunmod = 0
	var/last_heat_stunmod = 0
	var/regrowtimer

	smells_like = "putrid scales"

/datum/species/lizard/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_lizard_name(gender)

	var/randname = lizard_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname


/datum/species/lizard/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/H)
	..()
	last_heat_stunmod = heat_stunmod  //Saves previous mod
	if(H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		heat_stunmod = 1		//lizard gets faster when warm
	else if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !HAS_TRAIT(H, TRAIT_RESISTCOLD))
		switch(H.bodytemperature)
			if(200 to BODYTEMP_COLD_DAMAGE_LIMIT)	//but slower
				heat_stunmod = -1
			if(120 to 200)
				heat_stunmod = -2		//and slower
			else
				heat_stunmod = -3		//and sleepier as they get colder
	else
		heat_stunmod = 0
	var/heat_stun_mult = 1.1**(last_heat_stunmod - heat_stunmod) //1.1^(difference between last and current values)
	if(heat_stun_mult != 1) 		//If they're the same 1.1^0 is 1, so no change, if we go up we divide by 1.1	
		stunmod *= heat_stun_mult 	//however many times, and if it goes down we multiply by 1.1
						//This gets us an effective stunmod of 0.91, 1, 1.1, 1.21, 1.33, based on temp

/datum/species/lizard/spec_life(mob/living/carbon/human/H)
	. = ..()
	if((H.client && H.client.prefs.read_preference(/datum/preference/toggle/mood_tail_wagging)) && !is_wagging_tail() && H.mood_enabled)
		var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
		if(!istype(mood) || !(mood.shown_mood >= MOOD_LEVEL_HAPPY2)) 
			return
		var/chance = 0
		switch(mood.shown_mood)
			if(0 to MOOD_LEVEL_SAD4)
				chance = -0.1
			if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
				chance = -0.01
			if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
				chance = 0.001
			if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
				chance = 0.1
			if(MOOD_LEVEL_HAPPY4 to INFINITY)
				chance = 1
		if(prob(abs(chance)))
			switch(SIGN(chance))
				if(1)
					H.emote("wag")
				if(-1)
					stop_wagging_tail(H)
	if(!H.getorganslot(ORGAN_SLOT_TAIL) && !regrowtimer)
		regrowtimer = addtimer(CALLBACK(src, .proc/regrow_tail, H), 20 MINUTES, TIMER_UNIQUE)

/datum/species/lizard/proc/regrow_tail(mob/living/carbon/human/H)
	if(!H.getorganslot(ORGAN_SLOT_TAIL) && H.stat != DEAD)
		mutant_bodyparts |= "tail_lizard"
		H.visible_message("[H]'s tail regrows.","You feel your tail regrow.")
	
/datum/species/lizard/get_species_description()
	return /*"The militaristic Lizardpeople hail originally from Tizira, but have grown \
		throughout their centuries in the stars to possess a large spacefaring \
		empire: though now they must contend with their younger, more \
		technologically advanced Human neighbours."*/

/datum/species/lizard/get_species_lore()
	return list(
		"TBD",/*
		"The face of conspiracy theory was changed forever the day mankind met the lizards.",

		"Hailing from the arid world of Tizira, lizards were travelling the stars back when mankind was first discovering how neat trains could be. \
		However, much like the space-fable of the space-tortoise and space-hare, lizards have rejected their kin's motto of \"slow and steady\" \
		in favor of resting on their laurels and getting completely surpassed by 'bald apes', due in no small part to their lack of access to plasma.",

		"The history between lizards and humans has resulted in many conflicts that lizards ended on the losing side of, \
		with the finale being an explosive remodeling of their moon. Today's lizard-human relations are seeing the continuance of a record period of peace.",

		"Lizard culture is inherently militaristic, though the influence the military has on lizard culture \
		begins to lessen the further colonies lie from their homeworld - \
		with some distanced colonies finding themselves subsumed by the cultural practices of other species nearby.",

		"On their homeworld, lizards celebrate their 16th birthday by enrolling in a mandatory 5 year military tour of duty. \
		Roles range from combat to civil service and everything in between. As the old slogan goes: \"Your place will be found!\"",
	*/)

// Override for the default temperature perks, so we can give our specific "cold blooded" perk.
/datum/species/lizard/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-empty",
		SPECIES_PERK_NAME = "Cold-blooded",
		SPECIES_PERK_DESC = "Lizardpeople have higher tolerance for hot temperatures, but lower \
			tolerance for cold temperatures. Additionally, they cannot self-regulate their body temperature - \
			they are as cold or as warm as the environment around them is. Stay warm!",
	))

	return to_add

/*
 Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = "ashlizard"
	limbs_id = "lizard"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,DIGITIGRADE,HAS_FLESH,HAS_BONE,HAS_TAIL)
	inherent_traits = list(TRAIT_NOGUNS) //yogs start - ashwalkers have special lungs and actually breathe
	mutantlungs = /obj/item/organ/lungs/ashwalker
	breathid = "n2" // yogs end
	species_language_holder = /datum/language_holder/lizard/ash

// yogs start - Ashwalkers now have ash immunity
/datum/species/lizard/ashwalker/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "ash"

/datum/species/lizard/ashwalker/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"

/*
 Lizard subspecies: DRACONIDS
 These guys only come from the dragon's blood bottle from lavaland. They're basically just lizards with all-around marginally better stats and fire resistance.
 Sadly they only get digitigrade legs. Can't have everything!
*/
/datum/species/lizard/draconid	
	name = "Draconid"
	id = "draconid"
	limbs_id = "lizard"
	fixed_mut_color = "A02720" 	//Deep red
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,DIGITIGRADE,HAS_FLESH,HAS_BONE,HAS_TAIL)
	inherent_traits = list(TRAIT_RESISTHEAT)	//Dragons like fire
	burnmod = 0.8
	brutemod = 0.9 //something something dragon scales
	punchdamagelow = 3
	punchdamagehigh = 12
	punchstunthreshold = 12	//+2 claws of powergaming

/datum/species/lizard/draconid/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "ash"

/datum/species/lizard/draconid/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"

// yogs end

/datum/species/lizard/has_toes()
	return TRUE
