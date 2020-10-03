/datum/species/polysmorph
	//Human xenopmorph hybrid
	name = "Polysmorph"
	id = "polysmorph"
	sexes = 0
	exotic_blood = /datum/reagent/polysmorphblood
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/xeno
	liked_food = GROSS | MEAT
	disliked_food = GRAIN | DAIRY | VEGETABLES | FRUIT
	no_equip = list(SLOT_SHOES)
	say_mod = "hisses"
	species_language_holder = /datum/language_holder/polysmorph
	coldmod = 0.75
	heatmod = 2
	acidmod = 0.90
	damage_overlay_type = "polysmorph"
	deathsound = 'sound/voice/hiss6.ogg'
	screamsound = 'sound/voice/hiss5.ogg'
	species_traits = list(NOEYESPRITES, AGENDER)
	inherent_traits = list(TRAIT_THERMAL_VISION)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	mutant_bodyparts = list("tail_polysmorph", "plasma_vessels", "dome", "dorsal_tubes", "teeth")
	default_features = list("tail_polysmorph" = "Polys", "plasma_vessels" = "None", "dome" = "None", "dorsal_tubes" = "No", "teeth" = "None")
	mutanttongue = /obj/item/organ/tongue/polysmorph
	mutanttail = /obj/item/organ/tail/polysmorph
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/polysmorph/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_polysmorph_name()

	var/randname = polysmorph_name()

	return randname
