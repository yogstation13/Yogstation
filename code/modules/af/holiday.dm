/datum/holiday/april_fools/celebrate()
	SSjob.set_overflow_role("Clown")
	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(roundstart_celebrate)))

/datum/holiday/april_fools/proc/roundstart_celebrate()
	var/obj/effect/landmark/observer_start/O = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	if(O)
		new/obj/machinery/anvil(O.loc)
