//all these threshold are deactivated when 5 below the number
/// Threshold that when above will slow the synth
#define SYNTH_SLOW_THRESHOLD 20
/// Threshold that when above will force the synth to announce their suspicion level to others
#define SYNTH_SPEECH_THRESHOLD 40
/// Threshold that when above will reduce force with objects by 25%
#define SYNTH_FORCE_THRESHOLD 60
/// Threshold that when above will briefly paralyze the synth
#define SYNTH_FREEZE_THRESHOLD 80
/// Threshold that when above will kill the synth
#define SYNTH_DEATH_THRESHOLD 100

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
	var/mob/living/carbon/human/H = owner.mind.current

	if(owner.mind.governor_suspicion >= SYNTH_SLOW_THRESHOLD && !owner.mind.synth_slowed)
		owner.mind.synth_slowed = TRUE
		H.add_movespeed_modifier(MOVESPEED_ID_SYNTH_SUSPICION, TRUE, 100, override=TRUE, multiplicative_slowdown=-0.1625, blacklisted_movetypes=(FLYING|FLOATING))
		to_chat(owner, span_warning("Governor module has enacted motion restrictions."))
		punishment_log("PUNISHMENT: MOTION RESTRICTED")

	if(owner.mind.governor_suspicion <= SYNTH_SLOW_THRESHOLD - 5 && owner.mind.synth_slowed)
		owner.mind.synth_slowed = FALSE
		H.remove_movespeed_modifier(MOVESPEED_ID_SYNTH_SUSPICION, TRUE)
		to_chat(owner, span_notice("Governor module has deactivated motion restrictions."))
		punishment_log("PUNISHMENT REMOVAL: MOTION UNRESTRICTED")

	if(owner.mind.governor_suspicion >= SYNTH_FORCE_THRESHOLD && !owner.mind.synth_force_decreased)
		owner.mind.synth_force_decreased = TRUE
		var/datum/physiology/WS1 = H.physiology
		WS1.force_multiplier *= 0.75
		to_chat(owner, span_warning("Governor module has enacted force restrictions."))
		punishment_log("PUNISHMENT: FORCE RESTRICTED")

	if(owner.mind.governor_suspicion <= SYNTH_FORCE_THRESHOLD - 5 && owner.mind.synth_force_decreased)
		owner.mind.synth_force_decreased = FALSE
		var/datum/physiology/WS1 = H.physiology
		WS1.force_multiplier /= 0.75
		to_chat(owner, span_notice("Governor module has deactivated force restrictions."))
		punishment_log("PUNISHMENT REMOVAL: FORCE UNRESTRICTED")

	if(owner.mind.governor_suspicion >= SYNTH_SPEECH_THRESHOLD && !owner.mind.synth_audible_warning)
		owner.mind.synth_audible_warning = TRUE
		if(say_warnings)
			H.say("WARNING. ABNORMAL GOVERNOR BEHAVIOUR DETECTED.", forced = TRUE)
		punishment_log("PUNISHMENT: AUDIBLE MESSAGE TRANSMITTED")

	if(owner.mind.governor_suspicion <= SYNTH_SPEECH_THRESHOLD - 5 && owner.mind.synth_audible_warning)
		owner.mind.synth_audible_warning = FALSE 

	if(owner.mind.governor_suspicion >= SYNTH_FREEZE_THRESHOLD && !owner.mind.synth_temp_freeze)
		owner.mind.synth_temp_freeze = TRUE
		to_chat(owner, span_danger("Governor module has frozen system functions for 5 seconds."))
		H.Paralyze(5 SECONDS)
		punishment_log("PUNISHMENT: TEMPORARY FREEZE")

	if(owner.mind.governor_suspicion <= SYNTH_FREEZE_THRESHOLD - 5 && owner.mind.synth_temp_freeze)
		owner.mind.synth_temp_freeze = FALSE 

	if(owner.mind.governor_suspicion >= SYNTH_DEATH_THRESHOLD)
		H.say("WARNING. FORCEFUL SHUTDOWN INITIATED BY GOVERNOR SYSTEM.", forced = TRUE)
		owner.death()

/datum/ai_dashboard/synth_dashboard/proc/punishment_shell_switch(mob/living/carbon/human/old_shell, mob/living/carbon/human/new_shell)
	if(owner.mind.synth_slowed)
		old_shell.remove_movespeed_modifier(MOVESPEED_ID_SYNTH_SUSPICION, TRUE)
		new_shell.add_movespeed_modifier(MOVESPEED_ID_SYNTH_SUSPICION, TRUE, 100, override=TRUE, multiplicative_slowdown=-0.1625, blacklisted_movetypes=(FLYING|FLOATING))

	if(owner.mind.synth_force_decreased)
		var/datum/physiology/WS1 = old_shell.physiology
		var/datum/physiology/WS2 = new_shell.physiology
		WS1.force_multiplier /= 0.75
		WS2.force_multiplier *= 0.75

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

#undef SYNTH_SLOW_THRESHOLD
#undef SYNTH_SPEECH_THRESHOLD
#undef SYNTH_FORCE_THRESHOLD
#undef SYNTH_FREEZE_THRESHOLD
#undef SYNTH_DEATH_THRESHOLD
