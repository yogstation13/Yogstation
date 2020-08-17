/datum/department_goal/med
	account = ACCOUNT_MED


// Clone 5 people or something
/datum/department_goal/med/cloning
	name = "Clone 5 people"
	desc = "Clone 5 people"
	reward = 50000

/datum/department_goal/med/cloning/check_complete()
	return GLOB.clones >= 5
