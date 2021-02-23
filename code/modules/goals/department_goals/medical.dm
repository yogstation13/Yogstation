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
	if([PERCENT(popcount[POPCOUNT_SURVIVORS]/total_players)] > 60)
		return TRUE

/datum/department_goal/med/survrate2
	name = "Ensure at least a 80% survival rate"
	desc = "When shift ends, 80% of the original crew must still be alive"

/datum/department_goal/med/survrate2/check_complete()
	if([PERCENT(popcount[POPCOUNT_SURVIVORS]/total_players)] > 80)
		return TRUE