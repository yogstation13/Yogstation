/obj/machinery/vr_sleeper/netmin
	desc = "A sleeper modified to alter the subconscious state of the user, allowing them to visit virtual worlds. This one has been modifed to allow the occupant to control remote exploration robots."


/obj/machinery/vr_sleeper/netmin/emag_act(mob/user)
	if(!GLOB.compsci_vr.emagged)
		GLOB.compsci_vr.emag()

/obj/machinery/vr_sleeper/netmin/get_vr_spawnpoint() //proc so it can be overridden for team games or something
	if(GLOB.compsci_vr.current_mission)
		return safepick(GLOB.compsci_mission_markers[GLOB.compsci_vr.current_mission.id])
	return safepick(GLOB.vr_spawnpoints[vr_category])

/obj/machinery/vr_sleeper/netmin/build_virtual_human(mob/living/carbon/human/H, location, var/datum/outfit/outfit, transfer = TRUE)
	. = ..()
	if(vr_human)
		GLOB.compsci_vr.human_occupant = vr_human

/obj/machinery/vr_sleeper/netmin/ui_act(action, params)
	if(action == "vr_connect")
		if(!GLOB.compsci_vr.can_join(usr))
			to_chat(usr, span_warning("Someone else is already connected!"))
			return
	. = ..() 
	