/datum/ai_project/synth_project/speed
	name = "Leg Actuator Overclock"
	description = "By overclocking the primary actuator in our legs, we should be able to speed up movement considerably."
	research_cost = 1500
	research_requirements_text = "None"
	category = SYNTH_PROJECT_MOBILITY

/datum/ai_project/synth_project/speed/run_project(force_run = FALSE)
	. = ..()
	synth.add_movespeed_modifier(type, TRUE, 100, override=TRUE, multiplicative_slowdown=-0.25, blacklisted_movetypes=(FLYING|FLOATING))

/datum/ai_project/synth_project/speed/stop()
	. = ..()
	synth.remove_movespeed_modifier(type, TRUE)
