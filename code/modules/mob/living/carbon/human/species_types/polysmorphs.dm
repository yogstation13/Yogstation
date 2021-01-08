/datum/species/polysmorph
	//Human xenopmorph hybrid
	name = "Polysmorph"
	id = "polysmorph"
	exotic_blood = /datum/reagent/toxin/acid //Hell yeah sulphuric acid blood
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/xeno
	liked_food = GROSS | MEAT
	disliked_food = GRAIN | DAIRY | VEGETABLES | FRUIT
	no_equip = list(SLOT_SHOES)
	say_mod = "hisses"
	species_language_holder = /datum/language_holder/polysmorph
	coldmod = 0.75
	heatmod = 1.5
	acidmod = 0.2 //Their blood is literally acid
	burnmod = 1.25
	damage_overlay_type = "polysmorph"
	deathsound = 'sound/voice/hiss6.ogg'
	screamsound = 'sound/voice/hiss5.ogg'
	species_traits = list(NOEYESPRITES, FGENDER, MUTCOLORS, NOCOLORCHANGE)
	inherent_traits = list(TRAIT_ACIDBLOOD)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	mutanteyes = /obj/item/organ/eyes/polysmorph
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	fixed_mut_color = "444466" //don't mess with this if you don't feel like manually adjusting the mutant bodypart sprites
	mutant_bodyparts = list("tail_polysmorph", "dome", "dorsal_tubes", "teeth", "legs")
	default_features = list("tail_polysmorph" = "Polys", "dome" = "None", "dorsal_tubes" = "No", "teeth" = "None", "legs" = "Normal Legs")
	mutanttongue = /obj/item/organ/tongue/polysmorph
	mutanttail = /obj/item/organ/tail/polysmorph
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/polysmorph/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_polysmorph_name()

	var/randname = polysmorph_name()

	return randname
