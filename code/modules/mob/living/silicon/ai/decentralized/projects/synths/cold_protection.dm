/datum/ai_project/synth_project/cold_protection
	name = "Internal Heating"
	description = "By dumping excess power into our internal motors, we should be able to produce enough heat to protect against the cold."
	research_cost = 1500
	research_requirements_text = "None"
	category = SYNTH_PROJECT_EMERGENCY_FUNCTIONS
	permanent_suspicion = 30

/datum/ai_project/synth_project/cold_protection/run_project(force_run = FALSE)
	. = ..()
	ADD_TRAIT(synth, TRAIT_RESISTCOLD, type)

/datum/ai_project/synth_project/cold_protection/stop()
	. = ..()
	REMOVE_TRAIT(synth, TRAIT_RESISTCOLD, type)
