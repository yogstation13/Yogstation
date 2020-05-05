/datum/job/chief_engineer
	exp_requirements = 720

/datum/job/chief_engineer/New()
	access += list(ACCESS_CAPTAIN,ACCESS_TCOM_ADMIN)
	minimal_access += ACCESS_TCOM_ADMIN
	return ..()
