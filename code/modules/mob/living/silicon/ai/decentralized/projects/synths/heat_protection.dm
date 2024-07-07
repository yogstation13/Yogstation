/datum/ai_project/synth_project/heat_protection
	name = "Internal Cooling"
	description = "By modifying our internal processes, we should be able to induce a cooling cycle using excess fluid."
	research_cost = 1500
	research_requirements_text = "None"
	category = SYNTH_PROJECT_EMERGENCY_FUNCTIONS
	permanent_suspicion = 30

/datum/ai_project/synth_project/heat_protection/run_project(force_run = FALSE)
	. = ..()
	ADD_TRAIT(synth, TRAIT_RESISTHEAT, type)

/datum/ai_project/synth_project/heat_protection/stop()
	. = ..()
	REMOVE_TRAIT(synth, TRAIT_RESISTHEAT, type)
