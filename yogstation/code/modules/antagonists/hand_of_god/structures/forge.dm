/obj/structure/destructible/hog_structure/forge
	name = "celestial forge"
	desc = "A structure, capable of forging and impoving magical materials."
	break_message = span_warning("With a flash, the celestial forge fells appart!") 
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield, /datum/hog_god_interaction/structure/research/weapons, /datum/hog_god_interaction/structure/research/armor)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "forge"
	icon_originalname = "forge"
	max_integrity = 100

/datum/hog_god_interaction/targeted/construction/lance
	name = "Construct a celestial forge"
	description = "Construct a celestial forge, that can research upgrades for your cult's items.."
	cost = 135
	time_builded = 35 SECONDS
	warp_name = "forge"
	warp_description = "a pulsating mass of energy in a form of a forge"
	structure_type = /obj/structure/destructible/hog_structure/forge
	max_constructible_health = 100
	integrity_per_process = 6
	icon_name = "forge_constructing"
