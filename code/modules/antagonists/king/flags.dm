/obj/structure/flag
	name = "flag"
	icon_state = "flag"
	desc = "A flag of a departament..."
	anchored = TRUE
	density = TRUE
	var/list/jobs = list()
	var/datum/antagonist/king/owner
	var/is_ownered = FALSE
	max_integrity = 99999999999 //Honk
	can_be_unanchored = FALSE
	flags_1 = RAD_NO_CONTAMINATE_1