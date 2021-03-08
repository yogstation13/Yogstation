/datum/department_goal/med
	account = ACCOUNT_MED


// Clone 5 people or something
/datum/department_goal/med/cloning
	name = "Clone 5 people"
	desc = "Clone 5 people"
	reward = 50000

/datum/department_goal/med/cloning/check_complete()
	return GLOB.clones >= 5

/datum/department_goal/med/survrate1
	name = "Ensure at least a 60% survival rate"
	desc = "When shift ends, 60% of the original crew must still be alive"

/datum/department_goal/med/survrate1/check_complete()
	var/survivors = 0
	var/ided = 0
	for(var/mob/M in GLOB.player_list)
		if(M.stat == DEAD)
			ided += 1
		else if(M.stat == CONSCIOUS || M.stat == UNCONSCIOUS || M.stat == SOFT_CRIT)
			survivors += 1
	if(ided == 0) // avoiding divide by zero
		return TRUE
	else
		if(survivors / ided >= 1.5) //for every dead person, there should be 1.5 alive people
			return TRUE
		else
			return FALSE

/datum/department_goal/med/survrate2
	name = "Ensure at least a 80% survival rate"
	desc = "When shift ends, 80% of the original crew must still be alive"

/datum/department_goal/med/survrate2/check_complete()
	var/survivors = 0
	var/ided = 0
	for(var/mob/M in GLOB.player_list)
		if(M.stat == DEAD)
			ided += 1
		else if(M.stat == CONSCIOUS || M.stat == UNCONSCIOUS || M.stat == SOFT_CRIT)
			survivors += 1
	if(ided == 0) // avoiding divide by zero
		return TRUE
	else
		if(survivors / ided >= 4) // for every dead person, there should be 4 alive people
			return TRUE
		else
			return FALSE