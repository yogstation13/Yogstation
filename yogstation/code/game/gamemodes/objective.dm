GLOBAL_LIST_INIT(infiltrator_objective_areas, typecacheof(list(/area/yogs/infiltrator_base, /area/syndicate_mothership, /area/shuttle/yogs/stealthcruiser)))

/datum/objective/assassinate/internal/check_completion()
	if(..())
		return TRUE
	return !considered_alive(target)
