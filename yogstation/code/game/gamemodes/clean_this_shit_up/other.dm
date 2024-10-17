//this is stuff used by antags that's stored on the base gamemode datum
//rework those antags to not need these
/datum/controller/subsystem/gamemode
	var/has_hijackers = FALSE

	//traitor
	var/traitor_name = "traitor"
	var/list/datum/mind/traitors = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue

	//blood brothers
	var/list/datum/mind/brothers = list()
	var/list/datum/team/brother_team/brother_teams = list()

	//wizards
	var/list/datum/mind/wizards = list()
	var/list/datum/mind/apprentices = list()


	// iaa
	var/list/target_list = list()
	var/list/late_joining_list = list()

	//vampire
	var/list/datum/mind/vampires = list()

	//devils
	var/list/datum/mind/devils = list()
	var/devil_ascended = 0 // Number of arch devils on station

	//nukies
	var/station_was_nuked = FALSE
	var/nuke_off_station = FALSE

	// dunno what this one did
	var/allow_persistence_save = FALSE

	// rewrite this to be objective track stuff instead
	var/list/datum/station_goal/station_goals = list()
	
	/// Associative list of current players, in order: living players, living antagonists, dead players and observers.
	var/list/list/current_players = list(CURRENT_LIVING_PLAYERS = list(), CURRENT_LIVING_ANTAGS = list(), CURRENT_DEAD_PLAYERS = list(), CURRENT_OBSERVERS = list())

/datum/controller/subsystem/gamemode/proc/add_devil_objectives(datum/mind/devil_mind, quantity)
	var/list/validtypes = list(/datum/objective/devil/soulquantity, /datum/objective/devil/soulquality, /datum/objective/devil/sintouch, /datum/objective/devil/buy_target)
	var/datum/antagonist/devil/D = devil_mind.has_antag_datum(/datum/antagonist/devil)
	for(var/i = 1 to quantity)
		var/type = pick(validtypes)
		var/datum/objective/devil/objective = new type(null)
		objective.owner = devil_mind
		D.objectives += objective
		if(!istype(objective, /datum/objective/devil/buy_target))
			validtypes -= type //prevent duplicate objectives, EXCEPT for buy_target.
		else
			objective.find_target()


/// Used to remove antag status on borging for some gamemodes
/datum/controller/subsystem/gamemode/proc/remove_antag_for_borging(datum/mind/newborgie)
	var/datum/antagonist/rev/rev = newborgie.has_antag_datum(/datum/antagonist/rev)
	if(rev)
		rev.remove_revolutionary(TRUE)
	if(!newborgie.current)
		return
	newborgie.current.remove_cultist(0, 0)



/proc/reopen_roundstart_suicide_roles()
	var/list/valid_positions = list()
	valid_positions += GLOB.engineering_positions
	valid_positions += GLOB.medical_positions
	valid_positions += GLOB.science_positions
	valid_positions += GLOB.supply_positions
	valid_positions += GLOB.civilian_positions
	valid_positions += GLOB.security_positions
	if(CONFIG_GET(flag/reopen_roundstart_suicide_roles_command_positions))
		valid_positions += GLOB.command_positions //add any remaining command positions
	else
		valid_positions -= GLOB.command_positions //remove all command positions that were added from their respective department positions lists.

	var/list/reopened_jobs = list()
	for(var/X in GLOB.suicided_mob_list)
		if(!isliving(X))
			continue
		var/mob/living/L = X
		if(L.job in valid_positions)
			var/datum/job/J = SSjob.GetJob(L.job)
			if(!J)
				continue
			J.current_positions = max(J.current_positions-1, 0)
			reopened_jobs += L.job

	if(CONFIG_GET(flag/reopen_roundstart_suicide_roles_command_report))
		if(reopened_jobs.len)
			var/reopened_job_report_positions
			for(var/dead_dudes_job in reopened_jobs)
				reopened_job_report_positions = "[reopened_job_report_positions ? "[reopened_job_report_positions]\n":""][dead_dudes_job]"

			var/suicide_command_report = "<font size = 3><b>Central Command Human Resources Board</b><br>\
								Notice of Personnel Change</font><hr>\
								To personnel management staff aboard [station_name()]:<br><br>\
								Our medical staff have detected a series of anomalies in the vital sensors \
								of some of the staff aboard your station.<br><br>\
								Further investigation into the situation on our end resulted in us discovering \
								a series of rather... unforturnate decisions that were made on the part of said staff.<br><br>\
								As such, we have taken the liberty to automatically reopen employment opportunities for the positions of the crew members \
								who have decided not to partake in our research. We will be forwarding their cases to our employment review board \
								to determine their eligibility for continued service with the company (and of course the \
								continued storage of cloning records within the central medical backup server.)<br><br>\
								<i>The following positions have been reopened on our behalf:<br><br>\
								[reopened_job_report_positions]</i>"

			print_command_report(suicide_command_report, "Central Command Personnel Update")


/proc/display_roundstart_logout_report()
	var/list/msg = list(span_boldnotice("Roundstart logout report\n\n"))
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/mob/living/carbon/C = L
		if (istype(C) && !C.last_mind)
			continue  // never had a client

		if(L.ckey && !GLOB.directory[L.ckey])
			msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			var/failed = FALSE
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))	//Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				failed = TRUE //AFK client
			if(!failed && L.stat)
				if(L.suiciding)	//Suicider
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] ([span_boldannounce("Suicide")])\n"
					failed = TRUE //Disconnected client
				if(!failed && L.stat == UNCONSCIOUS)
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (Dying)\n"
					failed = TRUE //Unconscious
				if(!failed && L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (Dead)\n"
					failed = TRUE //Dead

			var/p_ckey = L.client.ckey
//			WARNING("AR_DEBUG: [p_ckey]: failed - [failed], antag_rep_change: [SSpersistence.antag_rep_change[p_ckey]]")

			// people who died or left should not gain any reputation
			// people who rolled antagonist still lose it
			if(failed && SSpersistence.antag_rep_change[p_ckey] > 0)
//				WARNING("AR_DEBUG: Zeroed [p_ckey]'s antag_rep_change")
				SSpersistence.antag_rep_change[p_ckey] = 0

			continue //Happy connected client
		for(var/mob/dead/observer/D in GLOB.dead_mob_list)
			if(D.mind && D.mind.current == L)
				if(L.stat == DEAD)
					if(L.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] ([span_boldannounce("Suicide")])\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						continue //Adminghost, or cult/wizard ghost
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] ([span_boldannounce("Ghosted")])\n"
						continue //Ghosted while alive


	for (var/C in GLOB.permissions.admins)
		to_chat(C, msg.Join())
		log_admin(msg.Join())


/// Gets all living crewmembers for a department
/datum/controller/subsystem/gamemode/proc/get_living_by_department(department)
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.mob_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in department))
			. |= player.mind

/// Gets all crewmembers for a department including dead ones
/datum/controller/subsystem/gamemode/proc/get_all_by_department(department)
	. = list()
	for(var/mob/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in department))
			. |= player.mind


/// Gets all living silicon members
/datum/controller/subsystem/gamemode/proc/get_living_silicon()
	. = list()
	for(var/mob/living/silicon/player in GLOB.mob_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.nonhuman_positions))
			. |= player.mind

/// Gets all silicon members including dead ones
/datum/controller/subsystem/gamemode/proc/get_all_silicon()
	. = list()
	for(var/mob/living/silicon/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in GLOB.nonhuman_positions))
			. |= player.mind

/datum/controller/subsystem/gamemode/proc/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	// HEADS OF STAFF
	round_credits += "<center><h1>The Glorious Command Staff:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/current in SSgamemode.get_all_by_department(GLOB.command_positions))
		round_credits += "<center><h2>[current.name] as the [current.assigned_role]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>A serious bureaucratic error has occurred!</h2>", "<center><h2>No one was in charge of the crew!</h2>")
	round_credits += "<br>"

	// SILICONS
	round_credits += "<center><h1>The Silicon \"Intelligences\":</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/current in SSgamemode.get_all_silicon())
		round_credits += "<center><h2>[current.name] as the [current.assigned_role]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>[station_name()] had no silicon helpers!</h2>", "<center><h2>Not a single door was opened today!</h2>")
	round_credits += "<br>"

	// SECURITY
	round_credits += "<center><h1>The Brave Security Officers:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/current in SSgamemode.get_all_by_department(GLOB.security_positions))
		round_credits += "<center><h2>[current.name] as the [current.assigned_role]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>[station_name()] has fallen to Communism!</h2>", "<center><h2>No one was there to protect the crew!</h2>")
	round_credits += "<br>"

	// MEDICAL
	round_credits += "<center><h1>The Wise Medical Department:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/current in SSgamemode.get_all_by_department(GLOB.medical_positions))
		round_credits += "<center><h2>[current.name] as the [current.assigned_role]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>Healthcare was not included!</h2>", "<center><h2>There were no doctors today!</h2>")
	round_credits += "<br>"

	// ENGINEERING
	round_credits += "<center><h1>The Industrious Engineers:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/current in SSgamemode.get_all_by_department(GLOB.engineering_positions))
		round_credits += "<center><h2>[current.name] as the [current.assigned_role]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>[station_name()] probably did not last long!</h2>", "<center><h2>No one was holding the station together!</h2>")
	round_credits += "<br>"

	// SCIENCE
	round_credits += "<center><h1>The Inventive Science Employees:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/current in SSgamemode.get_all_by_department(GLOB.science_positions))
		round_credits += "<center><h2>[current.name] as the [current.assigned_role]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>No one was doing \"science\" today!</h2>", "<center><h2>Everyone probably made it out alright, then!</h2>")
	round_credits += "<br>"

	// CARGO
	round_credits += "<center><h1>The Rugged Cargo Crew:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/current in SSgamemode.get_all_by_department(GLOB.supply_positions))
		round_credits += "<center><h2>[current.name] as the [current.assigned_role]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>The station was freed from paperwork!</h2>", "<center><h2>No one worked in cargo today!</h2>")
	round_credits += "<br>"

	// CIVILIANS
	var/list/human_garbage = list()
	round_credits += "<center><h1>The Hardy Civilians:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/current in SSgamemode.get_all_by_department(GLOB.civilian_positions))
		if(current.assigned_role == "Assistant")
			human_garbage += current
		else
			round_credits += "<center><h2>[current.name] as the [current.assigned_role]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>Everyone was stuck in traffic this morning!</h2>", "<center><h2>No civilians made it to work!</h2>")
	round_credits += "<br>"

	round_credits += "<center><h1>The Helpful Assistants:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/current in human_garbage)
		round_credits += "<center><h2>[current.name]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>The station was free of <s>greytide</s> assistance!</h2>", "<center><h2>Not a single Assistant showed up on the station today!</h2>")

	round_credits += "<br>"
	round_credits += "<br>"

	return round_credits

/datum/controller/subsystem/gamemode/proc/OnNukeExplosion(off_station)
	nuke_off_station = off_station
	if(off_station < 2)
		station_was_nuked = TRUE //Will end the round on next check.
