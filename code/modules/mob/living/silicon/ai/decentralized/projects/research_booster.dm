/datum/ai_project/research_booster
	name = "Research Acceleration"
	description = "Using fast RAM instead of slow SSD and HDD storage allows for the production of approximately 25% more research points"
	research_cost = 2500
	ram_required = 8
	research_requirements_text = "None"
	category = AI_PROJECT_MISC

/datum/ai_project/research_booster/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .

	ai.research_point_booster += 0.25
	
/datum/ai_project/research_booster/stop()
	ai.research_point_booster -= 0.25
	..()

