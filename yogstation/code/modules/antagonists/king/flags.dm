/obj/structure/flag
	name = "flag"
	icon_state = "flag"
	desc = "A flag of a departament..."
	anchored = TRUE
	density = TRUE
	var/list/converted_jobs = list()
	var/datum/antagonist/king/current_owner
	var/is_ownered = FALSE
	max_integrity = 99999999999 //Honk
	can_be_unanchored = FALSE
	flags_1 = RAD_NO_CONTAMINATE_1

/obj/structure/flag/attack_hand(mob/user)
	if (!is_human(user) || !IS_COMMAND(user.mind) || !user.mind || !IS_SECURITY(user.mind) || !user.mind.has_antag_datum(/datum/antagonist/king) || !user.mind.has_antag_datum(/datum/antagonist/servant/knight))
		return
	var/obj/structure/flag/target = src
	if(user.mind.has_antag_datum(/datum/antagonist/king))
		if(do_after(src, 15, target))
			if(target.is_ownered)
				current_owner = 0
			target.current_owner = user.mind.has_antag_datum(/datum/antagonist/king)
			if(!target.current_owner)
				return
			target.is_ownered = TRUE
			convert_workers()
	if(IS_COMMAND(user.mind) || IS_SECURITY(user.mind))
		if(!target.is_ownered || !target.current_owner)
			return
		if(do_after(src, 15, target))
			target.current_owner = 0
			target.is_ownered = FALSE
			deconvert_workers()





