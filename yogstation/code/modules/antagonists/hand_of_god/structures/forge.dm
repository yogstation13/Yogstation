/obj/structure/destructible/hog_structure/forge
	name = "celestial forge"
	desc = "A structure, capable of forging and impoving magical materials."
	break_message = span_warning("With a flash, the celestial forge fells appart!") 
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield, /datum/hog_god_interaction/structure/research/weapons, /datum/hog_god_interaction/structure/research/armor)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "lance"
	icon_originalname = "lance"
	max_integrity = 65
