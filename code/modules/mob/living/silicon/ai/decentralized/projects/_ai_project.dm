GLOBAL_LIST_EMPTY(ai_projects)


/datum/ai_project
	var/name = "DEBUG"
	var/description = "DEBUG"
	var/research_progress = 0
	var/research_cost = 0
	var/ram_required = 0
	var/running = FALSE
	//Text for available()
	var/research_requirements

/datum/ai_project/proc/available()
	return TRUE

/datum/ai_project/test_project
	name = "Test Project"
	description = "I'm a test! How quirky"
	research_cost = 2
	ram_required = 1
	research_requirements = "None"
