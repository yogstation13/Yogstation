/datum/ai_project/synth_project
	for_synths = TRUE
	var/suspicion_gain_on_use = 0
	ram_required = 0
	var/permanent_suspicion = 0


/datum/ai_project/synth_project/run_project(force_run = FALSE, no_suspicion = FALSE)
	. = ..(force_run)
	if(!no_suspicion)
		synth.mind.suspicion_floor += permanent_suspicion
		synth.mind.governor_suspicion += permanent_suspicion

/datum/ai_project/synth_project/stop(no_suspicion = FALSE)
	. = ..()
	if(!no_suspicion)
		synth.mind.suspicion_floor -= permanent_suspicion
