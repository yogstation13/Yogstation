/datum/species/polysmorph
	//Human xenopmorph hybrid
	name = "Polysmorph"
	id = "polysmorph"
	default_color = "96BB00"
	sexes = 0
	exotic_blood = /datum/reagent/polysmorphblood //no work
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
	//var/fixed_mut_color = "" //to use MUTCOLOR with a fixed color that's independent of dna.feature["mcolor"]
	deathsound = 'sound/voice/hiss6.ogg'
	screamsound = 'sound/voice/hiss5.ogg'
	species_traits = list(AGENDER, NOEYESPRITES)
	inherent_traits = list(TRAIT_THERMAL_VISION)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	mutant_bodyparts = list("tail_polysmorph")
	mutanteyes = /obj/item/organ/eyes/polysmorph //no work
	mutanttongue = /obj/item/organ/tongue/polysmorph
	mutanttail = /obj/item/organ/tail/polysmorph
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

