/datum/objective/assassinate/internal/check_completion()
	if(..())
		return TRUE
	return !considered_alive(target)
