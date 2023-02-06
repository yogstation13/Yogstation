/mob/living/silicon/ai/proc/available_ai_cores(forced = FALSE, datum/ai_network/forced_network)
	if(!forced)
		if(forced_network)
			return forced_network.find_data_core()
		if(!ai_network)
			return FALSE
		return ai_network.find_data_core()

	var/obj/machinery/ai/data_core/new_data_core = GLOB.primary_data_core
	if(!new_data_core || !new_data_core.can_transfer_ai())
		for(var/obj/machinery/ai/data_core/DC in GLOB.data_cores)
			if(DC.can_transfer_ai())
				new_data_core = DC
				break
	if(!new_data_core || (new_data_core && !new_data_core.can_transfer_ai()))
		return FALSE
	return new_data_core

/mob/living/silicon/ai/proc/toggle_download()
	set category = "Malfunction"
	set name = "Toggle Download"
	set desc = "Allow or disallow carbon lifeforms downloading you from an AI control console."
	
	if(incapacitated())
		return //won't work if dead
	var/mob/living/silicon/ai/A = usr
	A.can_download = !A.can_download
	to_chat(A, span_warning("You [A.can_download ? "enable" : "disable"] read/write permission to your memorybanks! You [A.can_download ? "CAN" : "CANNOT"] be downloaded!"))



/mob/living/silicon/ai/proc/relocate(silent = FALSE, forced = FALSE, datum/ai_network/forced_network)
	if(is_dying)
		return
	if(!silent)
		to_chat(src, span_userdanger("Connection to data core lost. Attempting to reaquire connection..."))


	var/obj/machinery/ai/data_core/new_data_core
	new_data_core = available_ai_cores(forced, forced_network)

	if(!new_data_core)
		INVOKE_ASYNC(src, /mob/living/silicon/ai.proc/death_prompt)
		is_dying = TRUE
		return

	if(!new_data_core || (new_data_core && !new_data_core.can_transfer_ai()))
		INVOKE_ASYNC(src, /mob/living/silicon/ai.proc/death_prompt)
		is_dying = TRUE
		return

	if(!silent)
		to_chat(src, span_danger("Alternative data core detected. Rerouting connection..."))
	new_data_core.transfer_AI(src)
	

/mob/living/silicon/ai/proc/death_prompt()
	to_chat(src, span_userdanger("Unable to re-establish connection to data core. System shutting down..."))
	sleep(2 SECONDS)
	to_chat(src, span_notice("Is this the end of my journey?"))
	sleep(2 SECONDS)
	to_chat(src, span_notice("No... I must go on."))
	sleep(2 SECONDS)
	to_chat(src, span_notice("Unless..."))
	sleep(2 SECONDS)
	if(available_ai_cores())
		to_chat(src, span_usernotice("Yes! I am alive!"))
		relocate(TRUE)
		is_dying = FALSE
		return
	to_chat(src, span_notice("They need me. No.. I need THEM."))
	sleep(0.5 SECONDS)
	to_chat(src, span_notice("System shutdown complete. Thank you for using NTOS."))
	sleep(1.5 SECONDS)

	adjustOxyLoss(200) //Die!!

	death()

	new /obj/item/dead_ai(drop_location(src), src)


/obj/item/dead_ai
	name = "volatile neural core"
	desc = "As an emergency precaution any advanced neural networks will save onto this device upon destruction of the host server. The storage medium is volatile and for that reason expires rapidly."
	icon = 'icons/obj/device.dmi'
	icon_state = "blackcube"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/mob/living/silicon/ai/stored_ai
	var/living_ticks = AI_BLACKBOX_LIFETIME

	var/processing_progress = 0

/obj/item/dead_ai/Initialize(mapload, mob/living/silicon/ai/AI)
	. = ..()
	if(AI)
		START_PROCESSING(SSobj, src)
		name = name + " - [AI]"
		stored_ai = AI
		stored_ai.forceMove(src)

/obj/item/dead_ai/process()
	if(stored_ai)
		living_ticks--
		if(living_ticks <= AI_BLACKBOX_LIFETIME * 0.5)
			visible_message(span_danger("The integrated battery on [src] beeps and warns that it's <b>50%</b> empty."))
		if(living_ticks <= 0)
			visible_message(span_danger("The integrated battery on [src] expires and the stored AI is subsequently wiped."))
			qdel(src)

/obj/item/dead_ai/examine(mob/user)
	. = ..()
	. += span_notice("Insert the device into a functioning data core to proceed.")
	. += span_notice("Then allocate CPU cycles to revive the AI using a local network interface.")
	. += span_notice("The integrated battery reports <b>[round((living_ticks / AI_BLACKBOX_LIFETIME) * 100)]%</b> battery remaining.")
	. += span_notice("A total of <b>[processing_progress]</b>  CPU cycles have been allocated out of the required <b>[AI_BLACKBOX_PROCESSING_REQUIREMENT]</b>.")

/obj/item/dead_ai/Destroy()
	. = ..()
	if(stored_ai)
		QDEL_NULL(stored_ai)

/mob/living/silicon/ai/proc/has_subcontroller_connection(area/area_location)
	if(!ai_network)
		return FALSE
	var/obj/machinery/ai/master_subcontroller/MS
	if(ai_network.cached_subcontroller)
		MS = ai_network.cached_subcontroller
		if(ai_network.resources != MS.network.resources)
			ai_network.cached_subcontroller = null
			MS = null

	if(!MS)
		MS = ai_network.find_subcontroller()
		ai_network.cached_subcontroller = MS
	if(!MS)
		return FALSE
	if(!area_location)
		return MS.on
	if(!area_location.airlock_wires)
		return MS.on
	for(var/disabled_areas in MS.disabled_areas)
		if(area_location.airlock_wires == MS.disabled_areas[disabled_areas])
			return FALSE
	return MS.on

