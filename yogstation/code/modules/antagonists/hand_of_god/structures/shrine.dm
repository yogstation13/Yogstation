/obj/structure/destructible/hog_structure/shrine
	name = "shrine"
	desc = "A strange magical energy source."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	icon_originalname = "shrine"
	anchored = TRUE
	density = TRUE
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield)
	max_integrity = 500
	cost = 0
	time_builded = 0
	break_message = span_cult("The nexus explodes in a bright flash of light!") 
	constructor_range = 10