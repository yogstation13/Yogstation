/datum/job/captain
	exp_requirements = 300
	exp_type_department = EXP_TYPE_COMMAND

/datum/job/hop/New()
	access += ACCESS_CAPTAIN
	return ..()
