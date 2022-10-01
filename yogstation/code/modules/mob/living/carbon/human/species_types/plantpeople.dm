#define STATUS_MESSAGE_COOLDOWN 900

/datum/species/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "Phytosian"
	id = "pod" // We keep this at pod for compatibility reasons
	default_color = "59CE00"
	species_traits = list(MUTCOLORS,EYECOLOR,HAS_FLESH,HAS_BONE)
	mutant_bodyparts = list("pod_hair", "pod_flower")
	default_features = list("mcolor" = "0F0", "pod_hair" = "Cabbage", "pod_flower" = "Cabbage")
	rare_say_mod = list("rustles" = 10)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 2
	heatmod = 1.5
	coldmod = 1.5
	acidmod = 2
	speedmod = 0.33
	siemens_coeff = 0.75 //I wouldn't make semiconductors out of plant material
	punchdamagehigh = 8 //sorry anvil your balance choice was wrong imo and I WILL be changing this soon.
	punchstunthreshold = 9 
	payday_modifier = 0.7 //Neutrally viewed by NT
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/plant
	disliked_food = MEAT | DAIRY | MICE | VEGETABLES | FRUIT | GRAIN | JUNKFOOD | FRIED | RAW | GROSS | BREAKFAST | GRILLED | EGG | CHOCOLATE | SEAFOOD | CLOTH
	toxic_food = ALCOHOL
	liked_food = SUGAR
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/pod

	var/no_light_heal = FALSE
	var/light_heal_multiplier = 1
	var/dark_damage_multiplier = 1
	var/last_light_level = 0
	var/last_light_message = -STATUS_MESSAGE_COOLDOWN
	var/last_plantbgone_message = -STATUS_MESSAGE_COOLDOWN

/datum/species/pod/before_equip_job(datum/job/J, mob/living/carbon/human/H)
	to_chat(H, span_info("<b>You are a Phytosian.</b> Born from an engimatic plant called a 'Replica Pod'."))
	to_chat(H, span_info("Symbiotic plant-cells suffuse your skin and provide a protective layer that keeps you alive, and affords you regeneration unmatched by any other race."))
	to_chat(H, span_info("Darkness is your greatest foe. Even the cold expanses of space are lit by neighbouring stars, but the darkest recesses of the station's interior may prove to be your greatest foe."))
	to_chat(H, span_info("Heat and cold will damage your epidermis far faster than your natural regeneration can match."))
	to_chat(H, span_info("For more information on your race, see https://wiki.yogstation.net/wiki/Phytosian"))

/datum/species/pod/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.faction |= "plants"
	C.faction |= "vines"

/datum/species/pod/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.faction -= "plants"
	C.faction -= "vines"

/datum/species/pod/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD || H.stat == UNCONSCIOUS || (H.mind && H.mind.has_antag_datum(ANTAG_DATUM_THRALL)))
		return
	if(IS_BLOODSUCKER(H) && !HAS_TRAIT(H, TRAIT_MASQUERADE))
		return
	var/turf/T = get_turf(H)
	if(!T)
		return

	var/light_level = 0
	var/light_msg //for sending "low light!" messages to the player.
	var/light_amount = T.get_lumcount() //how much light there is in the place, affects receiving nutrition and healing
	if(istype(H.loc, /obj/mecha) || istype(H.loc, /obj/machinery/clonepod))
		//let's assume the interior is lit up
		light_amount = 0.6
	else if(!isturf(H.loc))
		//inside a container or something else, half the light because the container blocks it.
		// only get light inside the container in the future(?)
		light_amount *= 0.5
	if (light_amount)
		switch (light_amount)
			if (0.01 to 0.15)
				//very low light
				light_level = 1
				light_msg = span_warning("There isn't enough light here, and you can feel your body protesting the fact violently.")
				H.nutrition -= light_amount * 10
				//enough to make you faint but get back up consistently
				if(H.getOxyLoss() < 55)
					H.adjustOxyLoss(min(5 * dark_damage_multiplier, 55 - H.getOxyLoss()), 1)
				if((H.getOxyLoss() > 50) && H.stat)
					H.adjustOxyLoss(-4)
			if (0.16 to 0.3)
				//low light
				light_level = 2
				light_msg = span_warning("The ambient light levels are too low. Your breath is coming more slowly as your insides struggle to keep up on their own.")
				H.nutrition -= light_amount * 3
				//not enough to faint but enough to slow you down
				if(H.getOxyLoss() < 50)
					H.adjustOxyLoss(min(3 * dark_damage_multiplier, 50 - H.getOxyLoss()), 1)
			if (0.31 to 0.5)
				//medium, average, doing nothing for now
				light_level = 3
				if(H.nutrition <= NUTRITION_LEVEL_HUNGRY)	
					//just enough to function			
					H.nutrition += light_amount * 2
			if (0.51 to 0.75)
				//high light, regen here
				light_level = 4
				if(H.nutrition < NUTRITION_LEVEL_FED)
					H.nutrition += light_amount * 1.75				
				if ((H.stat != UNCONSCIOUS) && (H.stat != DEAD) && !no_light_heal)
					H.adjustOxyLoss(-0.5 * light_heal_multiplier, 1)
					H.heal_overall_damage(1 * light_heal_multiplier, 1 * light_heal_multiplier)
					//podpeople shouldn't be able to outheal radiation damage, making them functionally immune
					if(H.radiation < 500)
						H.adjustToxLoss(-0.5 * light_heal_multiplier, 1)
			if (0.76 to 1)
				//super high light
				light_level = 5
				if(H.nutrition < NUTRITION_LEVEL_FED)
					//this will give the positive fed moodlet instead of being stuck on "i'm so fat" for existing
					H.nutrition += light_amount * 1.5
				if ((H.stat != UNCONSCIOUS) && (H.stat != DEAD) && !no_light_heal)
					H.adjustOxyLoss(-0.5 * light_heal_multiplier, 1)
					H.heal_overall_damage(1.5 * light_heal_multiplier, 1.5 * light_heal_multiplier)
					if(H.radiation < 500)
						H.adjustToxLoss(-1 * light_heal_multiplier, 1)
	else
		//no light, this is baaaaaad
		light_level = 0
		light_msg = span_userdanger("Darkness! Your insides churn and your skin screams in pain!")
		H.nutrition -= 10
		//enough to make you faint for good, and eventually die
		if(H.getOxyLoss() < 60)
			H.adjustOxyLoss(min(5 * dark_damage_multiplier, 60 - H.getOxyLoss()), 1)
			H.adjustToxLoss(1 * dark_damage_multiplier, 1)

	if(light_level != last_light_level)
		last_light_level = light_level
		if(light_msg)
			last_light_message = world.time
			to_chat(H, light_msg)
	else
		if(world.time - last_light_message > STATUS_MESSAGE_COOLDOWN)
			if(light_msg)
				last_light_message = world.time
				to_chat(H, light_msg)

	if(H.nutrition > NUTRITION_LEVEL_FULL)
		H.nutrition = NUTRITION_LEVEL_FULL

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		if (H.stat != UNCONSCIOUS && H.stat != DEAD)
			if(light_level != last_light_level)
				last_light_level = light_level
				last_light_message = -STATUS_MESSAGE_COOLDOWN
				to_chat(H, span_userdanger("Your internal stores of light are depleted. Find a source to replenish your nourishment at once!"))
			H.take_overall_damage(2, 0)


/datum/species/pod/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * REAGENTS_METABOLISM)
		return 1

	if(chem.type == /datum/reagent/saltpetre)
		H.adjustFireLoss(-2.5*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * REAGENTS_METABOLISM)
		return 1

	if(chem.type == /datum/reagent/ammonia)
		H.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * REAGENTS_METABOLISM)
		return 1

	if(chem.type == /datum/reagent/plantnutriment/robustharvestnutriment)
		H.adjustToxLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
		for(var/V in H.reagents.reagent_list)//slow down the processing of harmful reagents.
			var/datum/reagent/R = V
			if(istype(R, /datum/reagent/toxin) || istype(R, /datum/reagent/drug))
				R.metabolization_rate = initial(R.metabolization_rate) * 0.5

		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * REAGENTS_METABOLISM)
		return 1

	if(chem.type == /datum/reagent/plantnutriment/left4zednutriment)
		H.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER)
		if(prob(10))
			if(prob(95))
				H.easy_randmut(NEGATIVE + MINOR_NEGATIVE)
			else
				H.easy_randmut(POSITIVE)

		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * REAGENTS_METABOLISM)
		return 1

	if(chem.type == /datum/reagent/plantnutriment/eznutriment)
		H.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustOxyLoss(-4*REAGENTS_EFFECT_MULTIPLIER)
		if(H.health < -50)
			H.adjustOxyLoss(-HUMAN_CRIT_MAX_OXYLOSS)

		if(chem.volume >= 15 && !is_type_in_list(chem, H.reagents.addiction_list))
			var/datum/reagent/new_reagent = new chem.type()
			H.reagents.addiction_list.Add(new_reagent)

		for(var/datum/reagent/addicted_reagent in H.reagents.addiction_list)
			if(istype(chem, addicted_reagent))
				addicted_reagent.addiction_stage = -15

		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * REAGENTS_METABOLISM)
		return 1

	if(chem.type == /datum/reagent/diethylamine)
		if(chem.overdosed)
			return 0

		if(chem.volume > 20)
			chem.overdosed = 1
			chem.overdose_start(H)
			return 0

		H.adjustBruteLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustFireLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustToxLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustOxyLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * REAGENTS_METABOLISM)
		return 1

	if(chem.type == /datum/reagent/consumable/sugar)
		if(chem.overdosed)
			return 0

		if(chem.volume > 40)
			chem.overdosed = 1
			chem.overdose_start(H)
			return 0

		light_heal_multiplier = 2
		dark_damage_multiplier = 3
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * REAGENTS_METABOLISM)
		//removal is handled in /datum/reagent/sugar/on_mob_delete() //so that was a lie
		
		//if there's none left after the removal, the light multiplier needs to go back to the default
		if(!H.reagents.has_reagent(/datum/reagent/consumable/sugar)) 
			light_heal_multiplier = initial(light_heal_multiplier)
			dark_damage_multiplier = initial(dark_damage_multiplier)
		return 1

	if(istype(chem, /datum/reagent/consumable/ethanol)) //istype so all alcohols work
		var/datum/reagent/consumable/ethanol/ethanol = chem
		H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustToxLoss(0.4*REAGENTS_EFFECT_MULTIPLIER)
		H.confused = max(H.confused, 1)
		if(ethanol.boozepwr > 80 && chem.volume > 30)
			if(chem.current_cycle > 50)
				H.IsSleeping(3)
			H.adjustToxLoss(4*REAGENTS_EFFECT_MULTIPLIER)
		return 0 // still get all the normal effects.

/datum/species/pod/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/H)
	..()
	if(!environment)
		return
	if(H.bodytemperature < 150 || H.bodytemperature > 400)
		no_light_heal = TRUE
	else
		no_light_heal = FALSE

/datum/species/pod/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	switch(P.type)
		if(/obj/item/projectile/energy/floramut)
			H.rad_act(rand(20, 30))
			H.adjustFireLoss(5)
			H.visible_message(span_warning("[H] writhes in pain as [H.p_their()] vacuoles boil."), span_userdanger("You writhe in pain as your vacuoles boil!"), span_italics("You hear the crunching of leaves."))
			if(prob(80))
				H.easy_randmut(NEGATIVE + MINOR_NEGATIVE)
			else
				H.easy_randmut(POSITIVE)
			H.domutcheck()
		if(/obj/item/projectile/energy/florayield)
			H.nutrition = min(H.nutrition+30, NUTRITION_LEVEL_FULL)

#undef STATUS_MESSAGE_COOLDOWN
