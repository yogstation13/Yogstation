/obj/structure/destructible/hog_structure/item_maker/forge
	name = "celestial workshop"
	desc = "a magical structure, capable of creating otherworldy objects"
	break_message = span_warning("bruh!") 
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_originalname = "lance"
	max_integrity = 65
    products = list(/datum/hog_product)

/datum/hog_product/sword
	name = "Sword"
	description = "a divine sword, that is a pretty robust weapon, and also can be upgraded to become even more powerfull."
	time_to_make = 1 SECONDS
	cost = 50
	result = /obj/item/hog_item/upgradeable/sword