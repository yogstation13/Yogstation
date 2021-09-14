GLOBAL_LIST_EMPTY(ai_projects)


/datum/ai_project
	var/name = "DEBUG"
	var/description = "DEBUG"
	var/research_requirements
	var/ram_required = 0
	var/running = FALSE

/datum/ai_project/proc/available()
	return TRUE
