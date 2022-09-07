/datum/species/polysmorph
	//Human xenopmorph hybrid
	name = "Polysmorph"
	id = "polysmorph"
	exotic_blood = /datum/reagent/toxin/acid //Hell yeah sulphuric acid blood
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/xeno
	liked_food = GROSS | MEAT | MICE
	disliked_food = GRAIN | DAIRY | VEGETABLES | FRUIT
	say_mod = "hisses"
	species_language_holder = /datum/language_holder/polysmorph
	coldmod = 0.75
	heatmod = 1.5
	acidmod = 0.2 //Their blood is literally acid
	burnmod = 1.25
	payday_modifier = 0.6 //Negatively viewed by NT
	damage_overlay_type = "polysmorph"
	sound = 'sound/voice/hiss6.ogg'
	screamsound = 'sound/voice/hiss5.ogg'
	species_traits = list(NOEYESPRITES, FGENDER, MUTCOLORS, NOCOLORCHANGE, DIGITIGRADE, HAS_FLESH, HAS_BONE)
	inherent_traits = list(TRAIT_ACIDBLOOD, TRAIT_SKINNY)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	mutanteyes = /obj/item/organ/eyes/polysmorph
	mutantliver = /obj/item/organ/liver/alien
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	fixed_mut_color = "444466" //don't mess with this if you don't feel like manually adjusting the mutant bodypart sprites
	mutant_bodyparts = list("tail_polysmorph", "dome", "dorsal_tubes", "teeth", "legs")
	default_features = list("tail_polysmorph" = "Polys", "dome" = "None", "dorsal_tubes" = "No", "teeth" = "None", "legs" = "Normal Legs")
	mutanttongue = /obj/item/organ/tongue/polysmorph
	mutanttail = /obj/item/organ/tail/polysmorph
	mutantlungs = /obj/item/organ/lungs/xeno
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/polysmorph/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_polysmorph_name()

	var/randname = polysmorph_name()

	return randname

/datum/species/polysmorph/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	.=..()
	var/mob/living/carbon/human/H = C
	if(H.physiology)
		H.physiology.armor.wound += 10	//Pseudo-exoskeleton makes them harder to wound

/datum/species/polysmorph/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	.=..()
	if(C.physiology)
		C.physiology.armor.wound -= 10
