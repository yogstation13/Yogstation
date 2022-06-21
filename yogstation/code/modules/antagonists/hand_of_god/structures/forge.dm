/obj/structure/destructible/hog_structure/item_maker/forge
	name = "forge"
	desc = "you shouldn't see this"
	break_message = span_warning("bruh!") 
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_originalname = "lance"
	max_integrity = 65
    products = list(/datum/hog_product)