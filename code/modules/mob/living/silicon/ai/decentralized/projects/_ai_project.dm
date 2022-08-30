GLOBAL_LIST_EMPTY(ai_projects)

/datum/ai_project
	///Name of the project. This is used as an ID so please keep all names unique (Or refactor it to use an ID like you should)
	var/name = "DEBUG"
	var/description = "DEBUG"
	var/research_progress = 0
	var/category = AI_PROJECT_MISC
	///Research cost of project in seconds of CPU time.
	var/research_cost = 0
	var/ram_required = 0
	var/running = FALSE
	//Text for canResearch()
	var/research_requirements_text = "None"
	//list of typepaths of required projects
	var/research_requirements

	//Passive upgrades and abilities below

	///Should we be able to even run this program?
	var/can_be_run = TRUE 
	///Path to our ability if we have any
	var/ability_path = FALSE
	///If we have an ability how many CPU cycles do they take to charge?
	var/ability_recharge_cost = 0
	///How much CPU have we invested in charging it up?
	var/ability_recharge_invested = 0

	var/mob/living/silicon/ai/ai
	var/datum/ai_dashboard/dashboard

/datum/ai_project/New(new_ai, new_dash)
	ai = new_ai
	dashboard = new_dash
	if(!ai || !dashboard)
		qdel(src)
	..()

/datum/ai_project/proc/canResearch()
	if(!research_requirements)
		return TRUE
	for(var/P in research_requirements)
		if(!dashboard.has_completed_project(P))
			return FALSE
	return TRUE

/datum/ai_project/proc/run_project(force_run = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	if(!can_be_run)
		return FALSE
	if(!force_run)
		if(!canRun())
			return FALSE
	running = TRUE
	dashboard.running_projects += src
	return TRUE

/datum/ai_project/proc/switch_network(datum/ai_network/old_net, datum/ai_network/new_net)
	return TRUE

/datum/ai_project/proc/stop()
	SHOULD_CALL_PARENT(TRUE)
	running = FALSE
	dashboard.running_projects -= src
	return TRUE
	
//Important! This isn't for checking processing requirements. That is checked on the AI for ease of references (See ai_dashboard.dm). This is just for special cases (Like uhh, not wanting the program to run while X runs or similar)
/datum/ai_project/proc/canRun()
	SHOULD_CALL_PARENT(TRUE)
	return !running

//Run when project is finished. For passive upgrades or adding abilities.
/datum/ai_project/proc/finish()
	return

/datum/ai_project/proc/add_ability(datum/action/innate/ai/ability)
	var/datum/action/innate/ai/has_ability = locate(ability) in ai.actions
	if(has_ability)
		return FALSE

	var/datum/action/AC = new ability()
	AC.Grant(ai)
	return AC
