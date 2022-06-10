/obj/structure/hog_structure/lance/nexus
	name = "Nexus"
	desc = "There is a god's soul inside. Kill it, and the god will die."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	icon_originalname = "nexus"
	anchored = TRUE
	density = TRUE
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge)
	max_integrity = 500
	var/last_scream
	var/mob/camera/hog_god/god

