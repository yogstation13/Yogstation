/datum/species/piscis
	name = "Piscis"
	id = "piscis"
	say_mod = "bobbles"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,EYECOLOR)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_AQUATIC)
	mutant_bodyparts = list("tail_piscis")
	default_features = list("tail_piscis" = "Piscis")
	mutanttongue = /obj/item/organ/tongue/piscis
	mutanttail = /obj/item/organ/tail/piscis
	breathid = "o2"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	meat = /obj/item/reagent_containers/food/snacks/carpmeat/piscis
	skinned_type = /obj/item/stack/sheet/animalhide/piscis
	disliked_food =  SUGAR | JUNKFOOD | FRIED | GRILLED
	liked_food = MEAT | RAW | VEGETABLES 
	species_language_holder = /datum/language_holder/piscis


	

