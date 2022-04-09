/client/proc/ai_quick_access(obj/machinery/ai/data_core/M in GLOB.data_cores)
	set name = "View AI Variables"
	set category = "Admin"
	if (!istype(M))
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "AI Quick Access") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/selected_ai = input("Select an AI","Select an AI") as null|anything in GLOB.ai_list
	if(!selected_ai)
		return
	
	var/client/C = usr.client
	if(!C || !istype(C))
		return
	if(!C.holder)
		return
	C.debug_variables(selected_ai)
	

