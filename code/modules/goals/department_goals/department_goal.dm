
/datum/department_goal
	var/name = "Be nice."
	var/desc = "Be nice to each other for once."
	var/endround = TRUE // Whether it's only accomplished at the end of the round, or if it's something you complete midround
	var/completed = FALSE

	// Whether it ends once completed, or is an on-going thing with on-going payouts.
	var/continuous = 0 // If on-going, this will be the minimum time required between completions

	var/account // See code/__DEFINES/economy.dm

/datum/department_goal/New()
	SSYogs.department_goals += src
	if(SSticker.current_state == GAME_STATE_PLAYING)
		message_players("new")
	return ..()

/datum/department_goal/Destroy()
	SSYogs.department_goals -= src
	if(SSticker.current_state == GAME_STATE_PLAYING)
		message_players("ded")
	return ..()

// Should contain the conditions for completing it, not just checking whether the objective has *already* been completed
/datum/department_goal/proc/check_complete()
	return FALSE

// Should contain the effects on completing it, like paying the given department
/datum/department_goal/proc/on_complete(endOfRound = FALSE)
	if(!continuous || endOfRound)
		completed = TRUE
		if(!endOfRound)
			message_players("complet")
	else
		SSYogs.department_goals[src] = world.time + continuous

/datum/department_goal/proc/get_result()
	if(!completed && check_complete())
		on_complete(TRUE)
	return "<li>[name] : <span class='[completed ? "greentext'>C" : "redtext'>Not c"]ompleted</span></li>"

/datum/department_goal/proc/message_players(message)
	var/string = "Your department's goals have been updated, please have another look at them."
	switch(message)
		if("ded")
			string = "Your department no longer has the goal: " + name
		if("new")
			string = "Your department now has the goal: " + name
		if("complet")
			string = "Your department completed the goal: " + name
			
	var/list/occupationsToSendTo = list()
	for(var/datum/job/j in SSjob.occupations)
		if(j.paycheck_department == account)
			occupationsToSendTo += j.title

	for(var/obj/item/pda/p in GLOB.PDAs)
		if(p.ownjob in occupationsToSendTo)
			var/datum/signal/subspace/messaging/pda/signal = new(src, list(
				"name" = "Central Command",
				"job" = "Central Command",
				"message" = string,
				"language" = /datum/language/common, // NT only uses galactic common.
				"targets" = list("[p.owner] ([p.ownjob])")
			))
			var/obj/machinery/telecomms/message_server/linkedServer
			for(var/obj/machinery/telecomms/message_server/S in GLOB.telecomms_list)
				linkedServer = S
			linkedServer.receive_information(signal, null)

