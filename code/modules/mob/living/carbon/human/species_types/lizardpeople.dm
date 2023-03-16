#define LIZARD_SLOWDOWN "coldlizard" //define used for the lizard speedboost

/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Lizardperson"
	plural_form = "Lizardfolk"
	id = "lizard"
	say_mod = "hisses"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAS_TAIL,SCLERA)
	inherent_traits = list(TRAIT_COLDBLOODED)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_REPTILE)
	mutant_bodyparts = list("tail_lizard", "snout", "spines", "horns", "frills", "body_markings", "legs")
	mutanttongue = /obj/item/organ/tongue/lizard
	mutanttail = /obj/item/organ/tail/lizard
	coldmod = 0.67 //used to being cold, just doesn't like it much
	heatmod = 0.67 //greatly appreciate heat, just not too much
	action_speed_coefficient = 1.05 //claws aren't as dextrous as hands
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

/datum/species/lizard/movement_delay(mob/living/carbon/human/H)//to handle the slowdown based on cold
	. = ..()
	if(heat_stunmod && !HAS_TRAIT(H, TRAIT_IGNORESLOWDOWN) && H.has_gravity())
		H.add_movespeed_modifier(LIZARD_SLOWDOWN, update=TRUE, priority=100, multiplicative_slowdown= -heat_stunmod/3, blacklisted_movetypes=FLOATING)//between a 0.33 speedup and a 1 slowdown
	else if(H.has_movespeed_modifier(LIZARD_SLOWDOWN))
		H.remove_movespeed_modifier(LIZARD_SLOWDOWN)

/datum/species/lizard/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	C.remove_movespeed_modifier(LIZARD_SLOWDOWN)	

/datum/species/lizard/spec_fully_heal(mob/living/carbon/human/H)
	. = ..()
	H.remove_movespeed_modifier(LIZARD_SLOWDOWN)

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
	return "The first sentient beings encountered by the SIC outside of the Sol system, vuulen are the most \
		commonly encountered non-human species in SIC space. Despite being one of the most integrated species in the SIC, they \
		are also one of the most heavily discriminated against."

/datum/species/lizard/get_species_lore()
	return list(
		"Born on the planet of Sangris, vuulen evolved from raptor-like creatures and quickly became the \
		dominant species thanks to the warm climate of the planet and their intelligence combined with relatively \
		dexterous claws. Vuulen developed similarly to humans technologically and geopolitically, mastering fire, \
		agriculture, writing, metalworking, architecture, and the applications of plasma; empires rose and fell; \
		varied and rich cultures emerged and grew. By the time first contact occurred between humans and vuulen, \
		the latter were a kind of medieval age, having even dabbled with the bluespace crystals naturally present \
		on the planet, albeit without success.",
 
		"The SIC was highly interested in Sangris for two reasons when it was discovered. The first was the \
		discovery of sapient life. The second was the great plethora of plasma and bluespace located on the planet. \
		A diplomatic team was quickly assembled, but the first contact turned violent. Afterwards, the SIC waged war \
		to conquer Sangris, doing so in a year due to the gap of technology and size between the two civilizations. \
		The remaining vuulek powers were assimilated into the newly-formed Opsillian Republic, and humans began populating the \
		planet. Vuulen were not citizens of the SIC, but still under its control through the Opsillian Republic. \
		Slavery was common, and most slaves were pressed into hazardous conditions in the collection or processing \
		of several of the planet's rich plasma veins. As time went on, the vuulen became gradually more accepted into \
		the human society. Finally, in 2463, the official interdiction of slavery was passed, and vuulen became full \
		citizens of the SIC. The Opsillian Republic went from a mere puppet state to a somewhat independent and legitimate government, \
		though many human companies continued to exploit vuulen as workers, as labor laws for non-humans \
		offered significantly less privilege than what would be expected.",
 
		"Vuulek communities are organized in clans, though their impact on the culture of the individuals is limited. \
		They tend to live like humans due to their colonization,  only occasionally practicing some of \
		their clan traditions. Despite efforts to integrate vuulen into the SIC through establishments such \
		as habituation stations, a certain pridefulness nonetheless survived amongst vuulen, as they're often \
		eager to prove their worth and qualities. In addition, strength and honor are still values commonly held \
		by vuulen. Awareness of the past atrocities committed against vuulen by the SIC vary greatly \
		between individuals, both amongst humans and vuulen.",
 
		"Today, the vuulek societies have been almost completely assimilated in the SIC, \
		and vuulen are now considered SIC citizens and claim almost all the same rights as humans \
		do. However, lawyers still struggle in rigged courts to try and claim a sense of equality \
		for all those who exist in the SIC as honest citizens. Humans and vuulen exist side by side \
		across the SIC in harmony, but without much fraternity. While full-blown hostility is rare, \
		prejudice is common.",
	)

// Override for the default temperature perks, so we can give our specific "cold blooded" perk.
/datum/species/lizard/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-empty",
		SPECIES_PERK_NAME = "Cold-blooded",
		SPECIES_PERK_DESC = "Lizardpeople have difficulty regulating their body temperature, they're not quite as affected by the temperature itself though.",
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

//Ash walker shaman, worse defensive stats, but better at surgery and have a healing touch ability
/datum/species/lizard/ashwalker/shaman
	name = "Ash Walker Shaman"
	id = "ashlizardshaman"
	armor = -1 //more of a support than a standard ashwalker, don't get hit
	brutemod = 1.15
	burnmod = 1.15
	speedmod = -0.1 //similar to ethereals, should help with saving others
	punchdamagehigh = 7
	punchstunthreshold = 7
	action_speed_coefficient = 0.9 //they're smart and efficient unlike other lizards
	var/obj/effect/proc_holder/spell/targeted/touch/healtouch/goodtouch

//gives the heal spell
/datum/species/lizard/ashwalker/shaman/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()	
	goodtouch = new /obj/effect/proc_holder/spell/targeted/touch/healtouch
	C.AddSpell(goodtouch)

//removes the heal spell
/datum/species/lizard/ashwalker/shaman/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(goodtouch)
		C.RemoveSpell(goodtouch)

//basic touch ability that heals brute and burn, only accessed by the ashwalker shaman
/obj/effect/proc_holder/spell/targeted/touch/healtouch
	name = "healing touch"
	desc = "This spell charges your hand with the vile energy of the Necropolis, permitting you to undo some external injuries from a target."
	hand_path = /obj/item/melee/touch_attack/healtouch

	school = "evocation"
	panel = "Ashwalker"
	charge_max = 20 SECONDS
	clothes_req = FALSE
	antimagic_allowed = TRUE

	action_icon_state = "spell_default"

/obj/item/melee/touch_attack/healtouch
	name = "\improper healing touch"
	desc = "A blaze of life-granting energy from the hand. Heals minor to moderate injuries."
	catchphrase = "BE REPLENISHED!!"
	on_use_sound = 'sound/magic/staff_healing.ogg'
	icon_state = "touchofdeath" //ironic huh
	item_state = "touchofdeath"
	var/healamount = 20 //total of 40 assuming they're hurt by both brute and burn

/obj/item/melee/touch_attack/healtouch/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE)) //no healing yourself
		return
	if(!user.can_speak_vocal())
		to_chat(user, span_notice("You can't get the words out!"))
		return
	var/mob/living/M = target
	new /obj/effect/temp_visual/heal(get_turf(M), "#899d39")
	M.heal_overall_damage(healamount, healamount, 0, BODYPART_ANY, TRUE) //notice it doesn't heal toxins, still need to learn chems for that
	return ..()
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
	inherent_traits = list(TRAIT_RESISTHEAT)	//Dragons like fire, not cold blooded because they generate fire inside themselves or something
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

#undef LIZARD_SLOWDOWN
