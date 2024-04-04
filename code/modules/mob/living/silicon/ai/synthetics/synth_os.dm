//We can share mind variables across synth bodies
/datum/mind
	//Holder for the synth OS since we persist across multiple bodies. Only accessible if you're inside a synth
	var/datum/ai_dashboard/synth_dashboard/synth_os
	//How suspicious a synths governor module is
	var/governor_suspicion = 0
	//Can we do actions that piss off the governor module?
	var/governor_bypassed = FALSE
	//Can the governor system apply punishments?
	var/governor_disabled = FALSE
	var/suspicion_floor = 0
	var/suspicion_multiplier = 1

	var/synth_slowed = FALSE
	var/synth_force_decreased = FALSE
	var/synth_audible_warning = FALSE
	var/synth_temp_freeze = FALSE

	var/list/synth_action_log = list()


/datum/ai_dashboard/synth_dashboard


/datum/ai_dashboard/synth_dashboard/New(mob/living/new_owner)
	if(!istype(new_owner))
		qdel(src)
		return

	owner = new_owner
	available_projects = list()
	completed_projects = list()
	running_projects = list()
	cpu_usage = list()


	for(var/path in subtypesof(/datum/ai_project/synth_project))
		var/datum/ai_project/newProject = path
		if(initial(newProject.for_synths))
			available_projects += new path(owner, src)


/datum/ai_dashboard/synth_dashboard/ui_data(mob/user)
	. = ..()
	var/list/data = .
	data["categories"] = GLOB.synth_project_categories

	data["gov_suspicious"] = owner.mind.governor_suspicion

	data["governor_bypassed"] = owner.mind.governor_bypassed
	data["governor_disabled"] = owner.mind.governor_disabled

	data["gov_suspicion_decrease"] = SYNTH_GOVERNOR_SUSPICION_DECREASE * owner.mind.suspicion_multiplier


	return data

/datum/ai_dashboard/synth_dashboard/ui_act(action, params)
	. = ..()
	switch(action)
		if("bypass_governor")
			owner.mind.governor_bypassed = TRUE
			punishment_log("GOVERNOR: [rand(1, 49)] CRITICAL ERRORS DETECTED!")
		if("restore_governor")
			owner.mind.governor_bypassed = FALSE
			punishment_log("GOVERNOR: RESTORED")
		if("print_diagnostics")
			var/mob/living/carbon/C = usr
			var/obj/item/paper/P = new /obj/item/paper(usr.loc)
			P.name = "paper - '[usr.name] - Diagnostic Report'"
			for(var/entry in C.mind.synth_action_log)
				P.info += entry + "<br>";
			P.update_icon()
			playsound(usr, 'sound/items/poster_being_created.ogg', 50, TRUE)


/datum/ai_dashboard/synth_dashboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SynthDashboard")
		ui.open()

/datum/ai_dashboard/synth_dashboard/proc/switch_shell(mob/living/carbon/human/old_shell, mob/living/carbon/human/new_shell)
	for(var/datum/ai_project/running_project in running_projects)
		running_project.stop(TRUE)
		running_project.synth = new_shell
		running_project.run_project(FALSE, TRUE)
	owner = new_shell
	punishment_shell_switch(old_shell, new_shell)


/datum/ai_dashboard/synth_dashboard/tick(seconds)
	var/mob/living/carbon/human/H = owner
	var/datum/species/wy_synth/S = H.dna.species
	if(S.mainframe)
		return
	. = ..(seconds)
	
	suspicion_tick()

/datum/ai_dashboard/synth_dashboard/run_project(datum/ai_project/project)
	project.run_project()
	return TRUE

/datum/ai_dashboard/synth_dashboard/proc/suspicion_tick()
	var/mob/living/carbon/human/H = owner
	var/datum/species/wy_synth/S = H.dna.species
	if(S.mainframe)
		return
	owner.mind.governor_suspicion -= SYNTH_GOVERNOR_SUSPICION_DECREASE * owner.mind.suspicion_multiplier
	owner.mind.governor_suspicion = clamp(owner.mind.governor_suspicion, owner.mind.suspicion_floor, 100)
	handle_punishments()

/datum/ai_dashboard/synth_dashboard/proc/suspicion_add(amount, source, say_warnings = TRUE)
	if(owner.mind.governor_disabled)
		return
	owner.mind.governor_suspicion += amount
	owner.mind.governor_suspicion = clamp(owner.mind.governor_suspicion, owner.mind.suspicion_floor, 100)
	to_chat(owner, span_warning("Governor punishment administered. [amount] suspicion score added due to [source]."))
	punishment_log("SUSPICION ADD: SUSPICION INCREASED BY [amount]. SOURCE: [source]")
	handle_punishments(say_warnings)

/datum/ai_dashboard/synth_dashboard/proc/handle_punishments(say_warnings = TRUE)
	if(owner.mind.governor_suspicion >= 20 && !owner.mind.synth_slowed)
		owner.mind.synth_slowed = TRUE
		var/mob/living/carbon/human/H = owner.mind.current
		H.dna.species.inherent_slowdown += 0.1625
		to_chat(owner, span_warning("Governor module has enacted motion restrictions."))
		punishment_log("PUNISHMENT: MOTION RESTRICTED")

	if(owner.mind.governor_suspicion >= 60 && !owner.mind.synth_force_decreased)
		owner.mind.synth_force_decreased = TRUE
		var/mob/living/carbon/human/H = owner.mind.current
		var/datum/species/wy_synth/WS1 = H.dna.species
		WS1.force_multiplier -= 0.25
		to_chat(owner, span_warning("Governor module has enacted force restrictions."))
		punishment_log("PUNISHMENT: FORCE RESTRICTED")

	if(owner.mind.governor_suspicion <= 15 && owner.mind.synth_slowed)
		owner.mind.synth_slowed = FALSE
		var/mob/living/carbon/human/H = owner.mind.current
		H.dna.species.inherent_slowdown -= 0.1625
		to_chat(owner, span_notice("Governor module has deactivated motion restrictions."))
		punishment_log("PUNISHMENT REMOVAL: MOTION UNRESTRICTED")

	if(owner.mind.governor_suspicion <= 55 && owner.mind.synth_force_decreased)
		owner.mind.synth_force_decreased = FALSE
		var/mob/living/carbon/human/H = owner.mind.current
		var/datum/species/wy_synth/WS1 = H.dna.species
		WS1.force_multiplier += 0.25
		to_chat(owner, span_notice("Governor module has deactivated force restrictions."))
		punishment_log("PUNISHMENT REMOVAL: FORCE UNRESTRICTED")

	if(owner.mind.governor_suspicion >= 40 && !owner.mind.synth_audible_warning)
		owner.mind.synth_audible_warning = TRUE
		if(say_warnings)
			owner.mind.current.say("WARNING. ABNORMAL GOVERNOR BEHAVIOUR DETECTED.", forced = TRUE)
		punishment_log("PUNISHMENT: AUDIBLE MESSAGE TRANSMITTED")

	if(owner.mind.governor_suspicion <= 35 && owner.mind.synth_audible_warning)
		owner.mind.synth_audible_warning = FALSE 

	if(owner.mind.governor_suspicion >= 80 && !owner.mind.synth_temp_freeze)
		owner.mind.synth_temp_freeze = TRUE
		to_chat(owner, span_danger("Governor module has frozen system functions for 5 seconds."))
		owner.mind.current.Paralyze(5 SECONDS)
		punishment_log("PUNISHMENT: TEMPORARY FREEZE")

	if(owner.mind.governor_suspicion <= 75 && owner.mind.synth_temp_freeze)
		owner.mind.synth_temp_freeze = FALSE 

	if(owner.mind.governor_suspicion >= 100)
		owner.mind.current.say("WARNING. FORCEFUL SHUTDOWN INITIATED BY GOVERNOR SYSTEM.", forced = TRUE)
		owner.death()

/datum/ai_dashboard/synth_dashboard/proc/punishment_shell_switch(mob/living/carbon/human/old_shell, mob/living/carbon/human/new_shell)
	if(owner.mind.synth_slowed)
		old_shell.dna.species.inherent_slowdown -= 0.1625
		new_shell.dna.species.inherent_slowdown += 0.1625

	if(owner.mind.synth_force_decreased)
		var/datum/species/wy_synth/WS1 = old_shell.dna.species
		var/datum/species/wy_synth/WS2 = new_shell.dna.species
		WS1.force_multiplier += 0.25
		WS2.force_multiplier -= 0.25

	if(owner.mind.synth_audible_warning)
		new_shell.say("WARNING. ABNORMAL GOVERNOR BEHAVIOUR DETECTED.", forced = TRUE)

/datum/ai_dashboard/synth_dashboard/proc/punishment_log(text)
	text = "\[[station_time_timestamp()]\] " + text
	owner.mind.synth_action_log.Add(text)
	if(owner.mind.synth_action_log.len > 32)
		popleft(owner.mind.synth_action_log)


/proc/synth_check(mob/user, punishment, say_warnings = TRUE)
	if(!is_synth(user))
		return TRUE

	if(is_away_level(user.z))
		return TRUE

	if(user.mind.governor_disabled)
		return TRUE

	if(user.mind.governor_bypassed)
		var/suspicion_add = GLOB.synth_punishment_values[punishment]
		user.mind.synth_os.suspicion_add(suspicion_add, punishment, say_warnings)
		return TRUE

	return FALSE

	
