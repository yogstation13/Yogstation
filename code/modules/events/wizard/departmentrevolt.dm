/datum/round_event_control/wizard/deprevolt //stationwide!
	name = "Departmental Uprising"
	weight = 0 //An order that requires order in a round of chaos was maybe not the best idea. Requiescat in pace departmental uprising August 2014 - March 2015
	typepath = /datum/round_event/wizard/deprevolt
	max_occurrences = 1
	earliest_start = 0 MINUTES
	admin_setup = list(
		/datum/event_admin_setup/listed_options/departmental_revolt,
		/datum/event_admin_setup/question/departmental_revolt_annouce,
		/datum/event_admin_setup/question/departmental_revolt_dangerous
	)


///which department is revolting?
/datum/event_admin_setup/listed_options/departmental_revolt
	input_text = "Which department should revolt?"
	normal_run_option = "Random"

/datum/event_admin_setup/listed_options/departmental_revolt/get_list()
	return subtypesof(/datum/job_department)
	
/datum/event_admin_setup/listed_options/departmental_revolt/apply_to_event(datum/round_event/wizard/deprevolt/event)
	event.picked_department = chosen

/// Announce the separatist nation to the round?
/datum/event_admin_setup/question/departmental_revolt_annouce
	input_text = "Announce This New Independent State?"

/datum/event_admin_setup/question/departmental_revolt_annouce/apply_to_event(datum/round_event/wizard/deprevolt/event)
	event.announcement = chosen

/// Is it going to try fighting other nations?
/datum/event_admin_setup/question/departmental_revolt_dangerous
	input_text = "Dangerous Nation? This means they will fight other nations."

/datum/event_admin_setup/question/departmental_revolt_dangerous/apply_to_event(datum/round_event/wizard/deprevolt/event)
	event.dangerous = chosen



/datum/round_event/wizard/deprevolt
	///which department is revolting?
	var/picked_department
	/// Announce the separatist nation to the round?
	var/announcement = FALSE
	/// Is it going to try fighting other nations?
	var/dangerous = TRUE


/datum/round_event/wizard/deprevolt/start()
	var/list/independent_departments = list() ///departments that are already independent, these will be disallowed to be randomly picked
	var/list/cannot_pick = list() ///departments that are already independent, these will be disallowed to be randomly picked
	for(var/datum/antagonist/separatist/separatist_datum in GLOB.antagonists)
		if(!separatist_datum.nation)
			continue
		independent_departments |= separatist_datum.nation
		cannot_pick |= separatist_datum.nation.nation_department

	var/department
	if(picked_department)
		department = picked_department
	else
		department = pick(list("Uprising of Assistants", "Medical", "Engineering", "Science", "Supply", "Service", "Security") - cannot_pick)
		if(!department)
			message_admins("Department Revolt could not create a nation, as all the departments are independent! You have created nations, you madman!")
	var/list/jobs_to_revolt	= list()
	var/nation_name
	var/list/citizens = list()

	switch(department)
		if("Uprising of Assistants") //God help you
			jobs_to_revolt = list("Assistant")
			nation_name = pick("Assa", "Mainte", "Tunnel", "Gris", "Grey", "Liath", "Grigio", "Ass", "Assi")
		if("Medical")
			jobs_to_revolt = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Geneticist", "Virologist")
			nation_name = pick("Mede", "Healtha", "Recova", "Chemi", "Geneti", "Viro", "Psych")
		if("Engineering")
			jobs_to_revolt = list("Chief Engineer", "Station Engineer", "Atmospheric Technician")
			nation_name = pick("Atomo", "Engino", "Power", "Teleco")
		if("Science")
			jobs_to_revolt = list("Research Director","Scientist", "Roboticist")
			nation_name = pick("Sci", "Griffa", "Explosi", "Mecha", "Xeno", "Nani", "Cyto")
		if("Supply")
			jobs_to_revolt = list("Quartermaster", "Cargo Technician", "Shaft Miner")
			nation_name = pick("Cargo", "Guna", "Suppli", "Mule", "Crate", "Ore", "Mini", "Shaf")
		if("Service") //the few, the proud, the technically aligned
			jobs_to_revolt = list("Bartender", "Cook", "Botanist", "Clown", "Mime", "Janitor", "Chaplain")
			nation_name = pick("Honka", "Boozo", "Fatu", "Danka", "Mimi", "Libra", "Jani", "Religi")
		if("Security")
			jobs_to_revolt = GLOB.security_positions
			nation_name = pick("Securi", "Beepski", "Shitcuri", "Red", "Stunba", "Flashbango", "Flasha", "Stanfordi")

	nation_name += pick("stan", "topia", "land", "nia", "ca", "tova", "dor", "ador", "tia", "sia", "ano", "tica", "tide", "cis", "marea", "co", "taoide", "slavia", "stotzka")
	if(department == "Uprising of Assistants")
		var/prefix = pick("roving clans", "barbaric tribes", "tides", "bandit kingdom", "tribal society", "marauder clans", "horde")
		nation_name = "The [prefix] of [nation_name]"

	var/datum/team/nation/nation = new(null, jobs_to_revolt, department)
	nation.name = nation_name
	var/datum/team/department_target //dodges unfortunate runtime
	if(independent_departments.len)
		department_target = pick(independent_departments)
	nation.generate_nation_objectives(dangerous, department_target)

	for(var/i in GLOB.carbon_list)
		var/mob/living/carbon/human/possible_separatist = i
		if(!possible_separatist.mind)
			continue
		var/datum/mind/separatist_mind = possible_separatist.mind
		if(!separatist_mind.assigned_role)
			continue
		for(var/job in jobs_to_revolt)
			if(separatist_mind.assigned_role == job)
				citizens += possible_separatist
				separatist_mind.add_antag_datum(/datum/antagonist/separatist, nation, department)
				nation.add_member(separatist_mind)
				possible_separatist.log_message("Was made into a separatist, long live [nation_name]!", LOG_ATTACK, color="red")

	if(citizens.len)
		var/jobs_english_list = english_list(jobs_to_revolt)
		message_admins("The nation of [nation_name] has been formed. Affected jobs are [jobs_english_list]. Any new crewmembers with these jobs will join the secession.")
		if(announcement)
			var/announce_text = "The new independent state of [nation_name] has formed from the ashes of the [department] department!"
			if(department == "Uprising of Assistants") //the text didn't really work otherwise
				announce_text = "The assistants of the station have risen to form the new independent state of [nation_name]!"
			priority_announce(announce_text, "Secession from [GLOB.station_name]", has_important_message = TRUE)
	else
		message_admins("The nation of [nation_name] did not have enough potential members to be created.")
		qdel(nation)
