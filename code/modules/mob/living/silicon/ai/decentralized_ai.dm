/mob/living/silicon/ai/proc/available_ai_cores(forced = FALSE)
	if(!GLOB.data_cores.len)
		return FALSE
	
	if(!forced)
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



/mob/living/silicon/ai/proc/relocate(silent = FALSE, forced = FALSE)
	if(is_dying)
		return
	if(!silent)
		to_chat(src, span_userdanger("Connection to data core lost. Attempting to reaquire connection..."))


	var/obj/machinery/ai/data_core/new_data_core
	new_data_core = available_ai_cores(TRUE)

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

	QDEL_IN(src, 2 SECONDS)
