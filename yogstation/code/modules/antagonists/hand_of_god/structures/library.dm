/obj/structure/destructible/hog_structure/item_maker/library
	name = "librarium"
	desc = "A book, that is surrounded by clouds of energy"
	break_message = span_warning("the librarium suddenly vanishes!") 
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_originalname = "librarium"
	max_integrity = 75
	products = list(/datum/hog_product/cultbook)

/datum/hog_product/cultbook
	name = "Cult tome"
	description = "A powerfull magical artefact, that allows you to stun non-believers, to decent damage to foes, transfer energy, convert objects and prepare spells."
	time_to_make = 45 SECONDS
	cost = 120
	result = /obj/item/hog_item/book

/datum/hog_god_interaction/targeted/construction/library
	name = "Construct a librarium"
	description = "Construct a librarium, that can produce cult tomes and unlock advanced spells."
	cost = 200
	time_builded = 35 SECONDS
	warp_name = "librarium"
	warp_description = "A chaotic energy mass"
	structure_type = /obj/structure/destructible/hog_structure/item_maker/library
	max_constructible_health = 75
	integrity_per_process = 5
	icon_name = "librarium_constructing"