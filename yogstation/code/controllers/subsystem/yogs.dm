#define ROUND_END_ANNOUNCEMENT_TIME 105 //the time at which the game will announce that the shuttle can be called, in minutes.
#define REBWOINK_TIME 50 // Number of seconds before unclaimed tickets bwoink again and yell about being unclaimed

SUBSYSTEM_DEF(Yogs)
	name = "Yog Features"
	flags = SS_BACKGROUND
	init_order = -101 //last subsystem to initialize, and first to shut down

	loading_points = 0.1 SECONDS // Yogs -- loading times

	var/list/mentortickets //less of a ticket, and more just a log of everything someone has mhelped, and the responses
	var/endedshift = FALSE //whether or not we've announced that the shift can be ended
	var/last_rebwoink = 0 // Last time we bwoinked all admins about unclaimed tickets

	var/list/datum/department_goal/department_goals = list()

/datum/controller/subsystem/Yogs/Initialize()
	mentortickets = list()

	//PRIZEPOOL MODIFIER THING
	GLOB.arcade_prize_pool[/obj/item/grenade/plastic/glitterbomb/pink] = 1
	GLOB.arcade_prize_pool[/obj/item/toy/plush/goatplushie/angry] = 2
	GLOB.arcade_prize_pool[/obj/item/toy/plush/goatplushie/angry/realgoat] = 2
	GLOB.arcade_prize_pool[/obj/item/stack/tile/ballpit] = 2

	//MULTI-PORTAL HANDLER
	var/list/enters = list()
	var/list/exits_by_id = list()
	for(var/obj/effect/portal/permanent/one_way/multi/portal in GLOB.portals)
		if(portal.is_entry) // If an entry portal
			enters += portal
		else
			if(!exits_by_id[portal.id])
				exits_by_id[portal.id] = list()
			exits_by_id[portal.id] += get_turf(portal)
			qdel(portal)
	for(var/obj/effect/portal/permanent/one_way/multi/portal in enters)
		if(exits_by_id[portal.id])
			portal.linked_targets = exits_by_id[portal.id]

	//ACCENT GENERATOR
	var/list/accent_names = assoc_list_strip_value(GLOB.accents_name2file)
	var/regex/is_phrase = regex(@"\\b[\w \.,;'\?!]+\\b","i")
	var/regex/is_word = regex(@"\\b[\w\.,;'\?!]+\\b","i") // Should be very similar to the above regex, except it doesn't capture on spaces and so only hits plaintext words
	for(var/accent in accent_names)
		var/list/accent_lists = list(list(), list(), list())
		var/list/accent_regex2replace = strings(GLOB.accents_name2file[accent], accent, directory = "strings/accents") // Key is regex, value is replacement
		for(var/reg in accent_regex2replace)
			//So, a side-effect of encoding our regexes as JSON keys is that JSON actually does interpretation of some escape sequences.
			//For example, it converts \b into a backspace character
			//as well as converts \n into a newline one.
			//We need to fix this here if we want raw regexes to be stored plaintext in JSON, w/o the accent creator having to muddle around with escaping.
			var/original_reg = reg // Saved so we can use it as index later
			reg = replacetext(reg,ascii2text(8),@"\b") //Fix backspace
			reg = replacetext(reg,"\n",@"\n") //Fix newline
			reg = replacetext(reg,"\t",@"\t") //Fix tabbing
			if(findtext(reg,is_word)) // If a word
				reg = copytext(reg,3,length(reg)-1) // Remove the \b, because we'll be treating this as a straight thing to replace
				accent_lists[2][reg] =	accent_regex2replace[original_reg] // These numerical indices mark their priority
			else if(findtext(reg,is_phrase)) // If a phrase
				accent_lists[1][regex(reg,"gi")] = accent_regex2replace[original_reg]
			else
				accent_lists[3][regex(reg,"gi")] = accent_regex2replace[original_reg]
		GLOB.accents_name2regexes[accent] = accent_lists

	// Picking department goals
	// Engineering first
	generateGoalsFromSubtypes(/datum/department_goal/eng)

	// Then security
	generateGoalsFromSubtypes(/datum/department_goal/sec)

	// Then medical
	generateGoalsFromSubtypes(/datum/department_goal/med)

	// Then cargo
	generateGoalsFromSubtypes(/datum/department_goal/car)

	// Then service
	generateGoalsFromSubtypes(/datum/department_goal/srv)

	// Then science
	generateGoalsFromSubtypes(/datum/department_goal/sci)

	// Then spawn the papers with the goals on em on the heads' (and QM's) computers
	for(var/obj/machinery/computer/C in GLOB.machines)
		var/account


		if(istype(C, /obj/machinery/computer/card/minor/ce))
			account = ACCOUNT_ENG

		else if(istype(C, /obj/machinery/computer/cargo))
			account = ACCOUNT_CAR

		else if(istype(C, /obj/machinery/computer/card/minor/cmo))
			account = ACCOUNT_MED

		else if(istype(C, /obj/machinery/computer/card/minor/rd))
			account = ACCOUNT_SCI

		else if(istype(C, /obj/machinery/computer/card) && !istype(C, /obj/machinery/computer/card/minor))
			account = ACCOUNT_SRV

		else if(istype(C, /obj/machinery/computer/card/minor/hos))
			account = ACCOUNT_SEC

		else if(istype(C, /obj/machinery/computer/communications))
			account = "all" // Special case, we'll give em all the objectives

		if(account)
			if(!is_station_level(C.z))
				continue
			if(account == "all")
				var/obj/item/paper/P = new /obj/item/paper(C.loc)
				P.name = "paper - 'department goals'"
				P.info = ""
				var/list/listOfGoals = list()
				for(var/datum/department_goal/d in SSYogs.department_goals)
					if(!listOfGoals[d.account])
						listOfGoals[d.account] = list()
					listOfGoals[d.account] += d
				for(account in listOfGoals)
					P.info += "Goals for the [getDepartmentFromAccount(account)] department:<ul>"
					for(var/datum/department_goal/d in listOfGoals[account])
						P.info += d.get_name()
					P.info += "</ul><br>"
				P.update_icon()

			else
				var/obj/item/paper/P = new /obj/item/paper(C.loc)
				P.name = "paper - '[getDepartmentFromAccount(account)] department goals'"
				P.info = "<ul>"
				for(var/datum/department_goal/d in SSYogs.department_goals)
					if(d.account == account)
						P.info += d.get_name()
				P.info += "</ul>"
				P.update_icon()


	for(var/path in subtypesof(/datum/corporation))
		new path

	return ..()

/datum/controller/subsystem/Yogs/fire(resumed = 0)
	//END OF SHIFT ANNOUNCER
	if(world.time > (ROUND_END_ANNOUNCEMENT_TIME*600) && !endedshift && !(EMERGENCY_AT_LEAST_DOCKED))
		priority_announce("Crew, your shift has come to an end. [SSshuttle.emergency.mode != SHUTTLE_IDLE ? "\n You may call the shuttle whenever you find it appropriate." : ""]", "End of shift announcement", RANDOM_REPORT_SOUND)
		endedshift = TRUE

	//UNCLAIMED TICKET BWOINKER
	if(world.time - last_rebwoink > REBWOINK_TIME*10)
		last_rebwoink = world.time
		for(var/datum/admin_help/bwoink in GLOB.unclaimed_tickets)
			if(bwoink.check_owner())
				GLOB.unclaimed_tickets -= bwoink

	// Department goal checker
	if(department_goals.len && SSticker.current_state == GAME_STATE_PLAYING)
		for(var/datum/department_goal/dg in department_goals)
			if(dg.completed || dg.endround || (department_goals[dg] && world.time < department_goals[dg]))
				continue
			if(dg.check_complete())
				dg.complete()
			else if(dg.continuous && !dg.fail_if_failed)
				dg.continuing()

/**
  * Generates up to 5 department goals of the given type.
  *
  * Arguments:
  * * d - the given datum that we're getting the subtypes of.
  */
/datum/controller/subsystem/Yogs/proc/generateGoalsFromSubtypes(datum/d)
	var/list/goals = subtypesof(d)
	var/goalsSoFar = 0
	while(goals.len && goalsSoFar < 5)
		var/datum/typepath = pick_n_take(goals)
		var/datum/department_goal/goal = new typepath
		if(goal.is_available())
			goalsSoFar++
		else
			qdel(goal)

/**
  * Gets the correct string from the given department account. See code/__DEFINES/economy.dm
  *
  * Arguments:
  * * account - The account that you're getting the string from. IE ACCOUNT_CIV or ACCOUNT_ENG
  */
/datum/controller/subsystem/Yogs/proc/getDepartmentFromAccount(var/account)
	switch(account)
		if(ACCOUNT_CIV)
			return "Civilian"
		if(ACCOUNT_ENG)
			return "Engineering"
		if(ACCOUNT_SCI)
			return "Science"
		if(ACCOUNT_MED)
			return "Medical"
		if(ACCOUNT_SRV)
			return "Service"
		if(ACCOUNT_CAR)
			return "Cargo"
		if(ACCOUNT_SEC)
			return "Security"
		else
			return "N/A report this to coders, see .proc/getDepartmentFromAccount"
