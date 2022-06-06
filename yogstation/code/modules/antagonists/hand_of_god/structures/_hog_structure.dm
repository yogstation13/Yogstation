/obj/structure/hog_structure
	name = "generic HoG structure"
	desc = "Cry at SuperSlayer if you see this."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	anchored = TRUE
	density = FALSE
	var/datum/team/hog_team/cult
	var/list/god_actions = list()
	var/obj/item/prismatic_lance/weapon = null
	var/shield_integrity = 0
