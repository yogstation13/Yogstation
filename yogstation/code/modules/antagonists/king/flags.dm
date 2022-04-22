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

/obj/structure/flag/attack_hand(mob/user) //When someone tries to capture the flag.
	if (!ishuman(user) || !IS_COMMAND(user.mind) || !user.mind || !IS_SECURITY(user.mind) || !IS_KING(user) || !IS_KNIGHT(user))
		return
	var/obj/structure/flag/target = src
	if(IS_KING(user))
		if(do_after(src, 15, target))
			if(target.is_ownered)
				current_owner = 0
			target.current_owner = user.mind.has_antag_datum(/datum/antagonist/king)
			if(!target.current_owner)
				return
			target.is_ownered = TRUE
			current_owner.flags_owned += target
			convert_workers()
			return
	if(IS_COMMAND(user.mind) || IS_SECURITY(user.mind))
		if(!target.is_ownered || !target.current_owner)
			return
		if(do_after(src, 15, target))
			deconvert_workers()
			target.current_owner = 0
			target.is_ownered = FALSE


/obj/structure/flag/proc/convert_workers() //It picks every human, and checks, is his job in the flag joblist. Yeah.
	if(!src.current_owner || !src.is_ownered || (converted_jobs.len <= 0))
		return
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list) //We do a little trolling
		if(!H.mind)
			continue
		if(IS_KNIGHT(H))
			continue
		if(IS_KING(H))
			continue
		if(!SSjob.GetJob(H.mind.assigned_role))
			continue
		if(!H.mind.assigned_role in src.converted_jobs)
			continue
		if(IS_SERVANT(H))
			var/datum/antagonist/servant/ex_serv = H.mind.has_antag_datum(/datum/antagonist/servant)
			ex_serv.master.servants -= ex_serv
			H.mind.remove_antag_datum(/datum/antagonist/servant)
		H.mind.add_antag_datum(/datum/antagonist/servant)
		var/datum/antagonist/servant/serv = H.mind.has_antag_datum(/datum/antagonist/servant)
		serv.master = src.current_owner
		src.current_owner.servants += serv
	return


/obj/structure/flag/proc/deconvert_workers() //Same as convert_workers(), but used when security forces or command stuff re-capture the flag
	if(!src.current_owner || !src.is_ownered || (converted_jobs.len <= 0))
		return
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list) //We do a little trolling(again)
		if(!H.mind)
			continue
		if(IS_KNIGHT(H))
			continue
		if(IS_KING(H))
			continue
		if(!SSjob.GetJob(H.mind.assigned_role))
			continue
		if(!H.mind.assigned_role in src.converted_jobs)
			continue
		if(!IS_SERVANT(H))
			continue
		var/datum/antagonist/servant/ex_serv = H.mind.has_antag_datum(/datum/antagonist/servant)
		src.current_owner.servants -= ex_serv
		H.mind.remove_antag_datum(/datum/antagonist/servant)
	return











