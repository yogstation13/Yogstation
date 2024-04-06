/datum/ai_project/synth_project/speed
	name = "Leg Actuator Overclock"
	description = "By overclocking the primary actuator in a synthetic leg we should be able to speed up movement considerably"
	research_cost = 1500
	research_requirements_text = "None"
	category = SYNTH_PROJECT_MOBILITY

/datum/ai_project/synth_project/speed/run_project(force_run = FALSE)
	. = ..()
	synth.dna.species.inherent_slowdown -= 0.25

/datum/ai_project/synth_project/stop()
	. = ..()
	synth.dna.species.inherent_slowdown += 0.25
