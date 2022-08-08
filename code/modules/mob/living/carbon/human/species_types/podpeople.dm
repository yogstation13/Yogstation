// yogs - This file is mirrored to plantpeople.dm
/*
THIS FILE IS UNUSED AND NOT THE CORRECT FILE FOR WORKING WITH THE PLAYER CONTROLLED PODPEOPLE.
yogstation\code\modules\mob\living\carbon\human\species_types\plantpeople.dm IS THE PLAYER RACE FOR PLANT PEOPLE
DISREGUARD THIS FILE IF YOU'RE INTENDING TO CHANGE ASPECTS OF PLAYER CONTROLLED POD PEOPLE
*/
/datum/species/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "Podperson"
	id = "pod"
	default_color = "59CE00"
	species_traits = list(MUTCOLORS,EYECOLOR)
	inherent_traits = list(TRAIT_ALWAYS_CLEAN)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.5 //Ow my plant
	heatmod = 1.5 //Ow my plant
	siemen_coeff = 0.75 //I wouldn't make semiconductors out of plant material
	punchdamagehigh = 8 //I am being attacked by a dandelion
	punchstunthreshold = 9 //TF2 no-crits special
	payday_modifier = 0.7 //Neutrally viewed by NT
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/plant
	exotic_blood = /datum/reagent/water
	disliked_food = MEAT | DAIRY | SEAFOOD | MICE
	liked_food = VEGETABLES | FRUIT | GRAIN
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/species/pod/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.faction |= "plants"
	C.faction |= "vines"

/datum/species/pod/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.faction -= "plants"
	C.faction -= "vines"

/datum/species/pod/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	if(IS_BLOODSUCKER(H) && HAS_TRAIT(H, TRAIT_NODEATH))
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		H.adjust_nutrition(light_amount * 10)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(1,1, 0, BODYPART_ORGANIC)
			H.adjustOxyLoss(-1)
			if(H.radiation < 500)
				H.adjustToxLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/datum/species/pod/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/species/pod/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	switch(P.type)
		if(/obj/item/projectile/energy/floramut)
			if(prob(15))
				H.rad_act(rand(30,80))
				H.Paralyze(100)
				H.visible_message(span_warning("[H] writhes in pain as [H.p_their()] vacuoles boil."), span_userdanger("You writhe in pain as your vacuoles boil!"), span_italics("You hear the crunching of leaves."))
				if(prob(80))
					H.easy_random_mutate(NEGATIVE+MINOR_NEGATIVE)
				else
					H.easy_random_mutate(POSITIVE)
				H.random_mutate_unique_identity()
				H.random_mutate_unique_features()
				H.domutcheck()
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message(span_userdanger("The radiation beam singes you!"))
		if(/obj/item/projectile/energy/florayield)
			H.set_nutrition(min(H.nutrition+30, NUTRITION_LEVEL_FULL))
