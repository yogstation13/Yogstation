/datum/ai_project/room_lockdown
	name = "Room Lockdown"
	description = "This ability will allow you to close and bolt all working doors, and trigger the fire alarms in a clicked area after a short delay and announcement."
	research_cost = 2500
	ram_required = 0

	category = AI_PROJECT_CROWD_CONTROL
	
	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/room_lockdown
	ability_recharge_cost = 1750

/datum/ai_project/room_lockdown/finish()
	add_ability(ability_path)

/datum/action/innate/ai/ranged/room_lockdown
	name = "Room Lockdown"
	desc = "Closes and bolts all working doors and triggers the fire alarm in a clicked room. Takes 2.5 seconds to take effect, and expires after 20 seconds."
	button_icon_state = "lockdown"
	uses = 1
	delete_on_empty = FALSE
	enable_text = span_notice("You ready the lockdown signal.")
	disable_text = span_notice("You disarm the lockdown signal.")

/datum/action/innate/ai/ranged/room_lockdown/proc/lock_room(atom/target)
	if(target && !QDELETED(target))
		var/area/A = get_area(target)
		if(!A)
			return FALSE
		if(!is_station_level(A.z))
			return FALSE
		log_game("[key_name(usr)] locked down [A].")
		minor_announce("Lockdown commencing in area [A] within 2.5 seconds","Network Alert:", TRUE)
		addtimer(CALLBACK(src, PROC_REF(_lock_room), target), 2.5 SECONDS)
		return TRUE


/datum/action/innate/ai/ranged/room_lockdown/proc/_lock_room(atom/target)
	var/area/A = target
	for(var/obj/machinery/door/airlock/D in A.contents)
		if(istype(D, /obj/machinery/door/airlock/external))
			continue
		INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door/airlock, safe_lockdown))
		addtimer(CALLBACK(D, TYPE_PROC_REF(/obj/machinery/door/airlock, disable_safe_lockdown)), 20 SECONDS)
	A.firealert(usr.loc)
	addtimer(CALLBACK(A, TYPE_PROC_REF(/area, firereset)), 20 SECONDS)
			



/datum/action/innate/ai/ranged/room_lockdown/do_ability(mob/living/caller, params, atom/target)
	var/area/A = get_area(target)
	if(!A)
		to_chat(owner, span_warning("No area detected!"))
		return
	if(istype(A, /area/maintenance))
		to_chat(owner, span_warning("It is not possible to lockdown maintenance areas due to poor networking!"))
		return


	if(lock_room(A))
		adjust_uses(-1)
		to_chat(owner, span_notice("You lock [A]."))
		unset_ranged_ability(caller)

	return TRUE

/datum/action/innate/ai/ranged/room_lockdown/IsAvailable(feedback = FALSE)
	. = ..()
	if(uses < 1)
		to_chat(owner, span_danger("No uses left!"))
		return FALSE
