/obj/machinery/vr_sleeper/netmin
	desc = "A sleeper modified to alter the subconscious state of the user, allowing them to visit virtual worlds. This one has been modifed to allow the occupant to control remote exploration robots."


/obj/machinery/vr_sleeper/netmin/emag_act(mob/user)
	if(!GLOB.compsci_vr.emagged)
		GLOB.compsci_vr.emag()

/obj/machinery/vr_sleeper/netmin/get_vr_spawnpoint() //proc so it can be overridden for team games or something
	return safepick(GLOB.vr_spawnpoints[vr_category])
		

/obj/machinery/vr_sleeper/netmin/ui_act(action, params)
	if(action == "vr_connect")
		if(!GLOB.compsci_vr.can_join(usr))
			to_chat(usr, span_warning("Someone else is already connected!"))
			return
	. = ..() 
	
/obj/machinery/vr_sleeper/netmin/synth_only
	name = "virtual reality endpoint"
	desc = "A sleeper modified to alter the subconscious state of the user, allowing them to visit virtual worlds. This one has been modifed to allow only a synthetic to control remote exploration robots."

/obj/machinery/vr_sleeper/netmin/synth_only/ui_act(action, params)
	if(action == "vr_connect")
		if(!is_synth(usr))
			to_chat(usr, span_warning("Only synthetics may use this endpoint!"))
			return
		if(!GLOB.compsci_vr.can_join(usr))
			to_chat(usr, span_warning("Someone else is already connected!"))
			return
	. = ..() 
